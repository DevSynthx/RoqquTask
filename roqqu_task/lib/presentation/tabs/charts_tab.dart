import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                // Ensure the candles are properly sorted by time (oldest to newest)
                final sortedCandles = List<domain.Candle>.from(candles)
                  ..sort((a, b) => a.time.compareTo(b.time));

                return Column(
                  children: [
                    SfCartesianChart(
                      primaryXAxis: DateTimeAxis(),
                      primaryYAxis: NumericAxis(),
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
                        )
                      ],
                      tooltipBehavior: TooltipBehavior(enable: true),
                    ),
                    // _buildVolumeSection(sortedCandles),
                    const SizedBox(height: 16),
                  ],
                );
              } catch (e) {
                // Add error handling to help diagnose issues
                print('Error rendering chart: $e');
                return Center(child: Text('Error rendering chart: $e'));
              }
            },
            loading: () => SingleLoader(
                  height: 300,
                  width: double.infinity,
                ),
            error: (error, stackTrace) {
              if (kDebugMode) {
                return Center(
                  child: Text('Error loading chart data: $error'),
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
          error: (error, stackTrace) => Center(
            child: Text('Error loading chart data: $error'),
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
  int _selectedTimeIntervalIndex = 3; // Default to 1D

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
    if (_selectedTimeIntervalIndex != index) {
      setState(() {
        _selectedTimeIntervalIndex = index;
      });

      // Update the market config with the new interval
      final currentConfig = ref.read(marketConfigProvider);
      ref.read(marketConfigProvider.notifier).state = MarketConfig(
        symbol: currentConfig.symbol,
        interval: _getIntervalFromIndex(index),
      );
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

    final maxVolume = candles.fold<double>(
        0, (max, candle) => candle.volume > max ? candle.volume : max);

    return Container(
      height: 100,
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                candles.isNotEmpty
                    ? 20
                    : 0, // Ensure we only generate bars if we have data
                (index) {
                  final dataIndex = candles.length - 20 + index;
                  if (dataIndex < 0 || dataIndex >= candles.length) {
                    return Expanded(child: Container());
                  }

                  final volume = candles[dataIndex].volume;
                  final isGreen =
                      candles[dataIndex].close >= candles[dataIndex].open;

                  final height = maxVolume > 0 ? (volume / maxVolume * 60) : 0;

                  return Expanded(
                    child: Container(
                      height: height.toDouble(),
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      color: isGreen ? Colors.green : Colors.red,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
