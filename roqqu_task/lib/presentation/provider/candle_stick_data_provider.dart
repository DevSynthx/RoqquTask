import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roqqu_task/domain/model/candle_model.dart';
import 'package:roqqu_task/domain/repository/binance_repo.dart';
import 'package:roqqu_task/presentation/provider/data_source_provider.dart';
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
  Timer? _loadingTimer;
  bool _isDisposed = false;

  CandlesNotifier(this.repository, this.config)
      : super(const AsyncValue.loading()) {
    _subscribeToStream();
  }

  Future<void> _subscribeToStream() async {
    await _subscription?.cancel();
    _loadingTimer?.cancel();

    state = const AsyncValue.loading();

    try {
      _subscription =
          repository.getKlineStream(config.symbol, config.interval).listen(
        (candle) {
          if (_isDisposed) return;

          if (state is AsyncLoading) {
            state = AsyncValue.data([candle]);
          } else {
            state = AsyncValue.data(_updateCandlesList(candle));
          }
        },
        onError: (error) {
          if (_isDisposed) return;
          state = AsyncValue.error(error, StackTrace.current);
        },
      );

      //-------> Set a timer to show empty state if no data arrives
      _loadingTimer = Timer(const Duration(seconds: 10), () {
        if (_isDisposed) return;
        if (state is AsyncLoading) {
          state = const AsyncValue.data([]);
        }
      });
    } catch (e) {
      if (_isDisposed) return;
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  List<Candle> _updateCandlesList(Candle newCandle) {
    final currentCandles = state.value ?? [];
    final updatedList = List<Candle>.from(currentCandles);

    final existingIndex = updatedList.indexWhere(
      (c) =>
          c.time.millisecondsSinceEpoch ==
          newCandle.time.millisecondsSinceEpoch,
    );

    if (existingIndex >= 0) {
      updatedList[existingIndex] = newCandle;
    } else {
      updatedList.add(newCandle);
      if (updatedList.length > 100) {
        updatedList.removeAt(0);
      }
    }

    updatedList.sort((a, b) => a.time.compareTo(b.time));
    return updatedList;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _subscription?.cancel();
    _loadingTimer?.cancel();
    super.dispose();
  }
}
