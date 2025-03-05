import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roqqu_task/domain/model/order_book_model.dart';
import 'package:roqqu_task/domain/model/ticker_model.dart';
import 'package:roqqu_task/presentation/provider/data_source_provider.dart';

class MarketConfig {
  final String symbol;
  final String interval;

  MarketConfig({required this.symbol, required this.interval});

  MarketConfig copyWith({String? symbol, String? interval}) {
    return MarketConfig(
      symbol: symbol ?? this.symbol,
      interval: interval ?? this.interval,
    );
  }
}

//---------->  Market  configuration Provider
final marketConfigProvider = StateProvider<MarketConfig>((ref) {
  return MarketConfig(symbol: 'BTCUSDT', interval: '1m');
});

//---------->  Orderbook Provider
final orderbookProvider = StreamProvider<Orderbook>((ref) {
  final repository = ref.watch(binanceRepositoryProvider);
  final config = ref.watch(marketConfigProvider);

  return repository.getOrderbookStream(config.symbol);
});

//---------->  Ticker Provider
final tickerProvider = StreamProvider<Ticker>((ref) {
  final repository = ref.watch(binanceRepositoryProvider);
  final config = ref.watch(marketConfigProvider);

  return repository.getTickerStream(config.symbol);
});

//------->  Convenience provider for current price
final currentPriceProvider = Provider<double>((ref) {
  final tickerValue = ref.watch(tickerProvider);

  return tickerValue.when(
    data: (ticker) => ticker.lastPrice,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});
