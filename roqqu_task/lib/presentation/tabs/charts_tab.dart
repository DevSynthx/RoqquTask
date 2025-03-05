import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:roqqu_task/core/extension/currency_extension.dart';
import 'package:roqqu_task/presentation/provider/candle_stick_data_provider.dart';
import 'package:roqqu_task/domain/model/candle_model.dart' as domain;
import 'package:roqqu_task/presentation/provider/market_data_provider.dart';
import 'package:roqqu_task/presentation/utils/app_spacer.dart';
import 'package:roqqu_task/presentation/utils/loading_view.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CandleChart extends ConsumerWidget {
  const CandleChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candlesAsync = ref.watch(candlesProvider);
    return Column(
      children: [
        TimeIntervalView(),
        candlesAsync.when(
            data: (candles) {
              if (candles.isEmpty) {
                return const Center(child: Text('No chart data available'));
              }
              try {
                // -------> Ensures the candles are properly sorted by time (oldest to newest)
                final sortedCandles = List<domain.Candle>.from(candles)
                  ..sort((a, b) => a.time.compareTo(b.time));

                return Column(
                  children: [
                    SfCartesianChart(
                      primaryXAxis: DateTimeAxis(
                        labelStyle: TextStyle(fontSize: 10.sp),
                        majorGridLines: const MajorGridLines(width: 0),
                      ),
                      primaryYAxis: NumericAxis(
                        numberFormat: NumberFormat.currency(
                          locale: 'en_US',
                          symbol: '',
                          decimalDigits: 2,
                        ),
                        opposedPosition: true,
                        labelStyle: TextStyle(fontSize: 10.sp),
                        labelPosition: ChartDataLabelPosition.outside,
                        labelAlignment: LabelAlignment.center,
                      ),
                      zoomPanBehavior: ZoomPanBehavior(
                        enablePinching: true,
                        enablePanning: true,
                        enableDoubleTapZooming: true,
                      ),
                      series: <CandleSeries<domain.Candle, DateTime>>[
                        CandleSeries<domain.Candle, DateTime>(
                            dataSource: sortedCandles,
                            xValueMapper: (domain.Candle candle, _) =>
                                candle.time,
                            lowValueMapper: (domain.Candle candle, _) =>
                                candle.low,
                            highValueMapper: (domain.Candle candle, _) =>
                                candle.high,
                            openValueMapper: (domain.Candle candle, _) =>
                                candle.open,
                            closeValueMapper: (domain.Candle candle, _) =>
                                candle.close,
                            name: 'Price',
                            borderRadius: BorderRadius.all(Radius.circular(10)))
                      ],
                      tooltipBehavior: TooltipBehavior(enable: true),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              } catch (e) {
                log('Error rendering chart: $e');
                return Center(child: Text('Error rendering chart: $e'));
              }
            },
            loading: () => SingleLoader(
                  height: 200,
                  width: double.infinity,
                ),
            error: (error, stackTrace) {
              if (kDebugMode) {
                return SingleLoader(
                  height: 300,
                  width: double.infinity,
                );
              } else {
                return SingleLoader();
              }
            }),
        candlesAsync.when(
          data: (data) {
            return VolumeView(
              candles: data,
            );
          },
          loading: () => SingleLoader(
            height: 100,
            width: double.infinity,
          ),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(),
            ),
          ),
        )
      ],
    );
  }
}

class TimeIntervalView extends ConsumerStatefulWidget {
  const TimeIntervalView({super.key});

  @override
  ConsumerState<TimeIntervalView> createState() => _TimeIntervalViewState();
}

class _TimeIntervalViewState extends ConsumerState<TimeIntervalView> {
  final List<String> _timeIntervals = ['1H', '2H', '4H', '1D', '1W', '1M'];
  int _selectedTimeIntervalIndex = 3;
  bool _isUpdating = false;

  String _getIntervalFromIndex(int index) {
    switch (index) {
      case 0:
        return '1h';
      case 1:
        return '2h';
      case 2:
        return '4h';
      case 3:
        return '1d';
      case 4:
        return '1w';
      case 5:
        return '1M';
      default:
        return '1d';
    }
  }

  void _updateTimeInterval(int index) {
    if (_isUpdating) return;

    if (_selectedTimeIntervalIndex != index) {
      setState(() {
        _selectedTimeIntervalIndex = index;
        _isUpdating = true;
      });

      //------> Update the market config with the new interval
      final currentConfig = ref.read(marketConfigProvider);
      ref.read(marketConfigProvider.notifier).state = MarketConfig(
        symbol: currentConfig.symbol,
        interval: _getIntervalFromIndex(index),
      );

      //-------> Reset updating variable after a short delay
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _isUpdating = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text('Time', style: TextStyle(color: Colors.grey)),
          const Space(16),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _timeIntervals.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedTimeIntervalIndex;
                return GestureDetector(
                  onTap: () => _updateTimeInterval(index),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.grey[300] : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _timeIntervals[index],
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.grey,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Icon(Icons.bar_chart, color: Colors.grey[600]),
          const SizedBox(width: 8),
          const Icon(Icons.fullscreen, color: Colors.grey),
        ],
      ),
    );
  }
}

class VolumeView extends ConsumerWidget {
  final List<domain.Candle> candles;
  const VolumeView({super.key, required this.candles});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (candles.isEmpty) {
      return const Center(
        child: Text('No data available',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
      );
    }

    //---------->  Sort candles by time
    final sortedCandles = List<domain.Candle>.from(candles)
      ..sort((a, b) => a.time.compareTo(b.time));

    return Container(
      height: 150,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Volume',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('Vol(BTC):',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(width: 4),
              Text(
                candles.isNotEmpty ? candles.last.volume.toCompact() : '0',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 16),
              const Text('Vol(USDT):',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(width: 4),
              Text(
                candles.isNotEmpty
                    ? (candles.last.volume * candles.last.close).toCompact()
                    : '0',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SfCartesianChart(
              margin: EdgeInsets.zero,
              primaryXAxis: DateTimeAxis(
                dateFormat: DateFormat('MMM dd HH:mm'),
                labelStyle: const TextStyle(fontSize: 10),
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                labelIntersectAction: AxisLabelIntersectAction.hide,
                interval: 5,
              ),
              primaryYAxis: NumericAxis(
                isVisible: false,
              ),
              plotAreaBorderWidth: 0,
              series: <ColumnSeries<domain.Candle, DateTime>>[
                ColumnSeries<domain.Candle, DateTime>(
                  dataSource: sortedCandles,
                  xValueMapper: (domain.Candle candle, _) => candle.time,
                  yValueMapper: (domain.Candle candle, _) => candle.volume,
                  width: 0.9,
                  spacing: 0.1,
                  pointColorMapper: (domain.Candle candle, _) =>
                      candle.close >= candle.open ? Colors.green : Colors.red,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
