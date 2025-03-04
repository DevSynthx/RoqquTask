// Provider for candles
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roqqu_task/domain/model/candle_model.dart';
import 'package:roqqu_task/domain/repository/binance_repo.dart';
import 'package:roqqu_task/presentation/data_source_provider.dart';
import 'package:roqqu_task/presentation/provider/market_data_provider.dart';

final candlesProvider =
    StateNotifierProvider<CandlesNotifier, AsyncValue<List<Candle>>>((ref) {
  final repository = ref.watch(binanceRepositoryProvider);
  final config = ref.watch(marketConfigProvider);

  return CandlesNotifier(repository, config);
});

class CandlesNotifier extends StateNotifier<AsyncValue<List<Candle>>> {
  final BinanceRepository repository;
  final MarketConfig config;
  StreamSubscription<Candle>? _subscription;

  CandlesNotifier(this.repository, this.config)
      : super(const AsyncValue.loading()) {
    _subscribeToStream();
  }

  Future<void> _subscribeToStream() async {
    // Cancel any existing subscription
    await _subscription?.cancel();

    // Set loading state
    state = const AsyncValue.loading();

    try {
      // Initialize with empty list
      final List<Candle> candles = [];
      state = AsyncValue.data(candles);

      // Subscribe to stream
      _subscription =
          repository.getKlineStream(config.symbol, config.interval).listen(
        (candle) {
          // Update state with new candle
          state = AsyncValue.data(_updateCandlesList(candle));
        },
        onError: (error) {
          state = AsyncValue.error(error, StackTrace.current);
        },
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  List<Candle> _updateCandlesList(Candle newCandle) {
    final currentCandles = state.value ?? [];
    final updatedList = List<Candle>.from(currentCandles);

    // Find existing candle with the same timestamp
    final existingIndex = updatedList.indexWhere(
      (c) =>
          c.time.millisecondsSinceEpoch ==
          newCandle.time.millisecondsSinceEpoch,
    );

    if (existingIndex >= 0) {
      // Update existing candle
      updatedList[existingIndex] = newCandle;
    } else {
      // Add new candle
      updatedList.add(newCandle);

      // Keep only last 100 candles
      if (updatedList.length > 100) {
        updatedList.removeAt(0);
      }
    }

    // Sort by time
    updatedList.sort((a, b) => a.time.compareTo(b.time));

    return updatedList;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
