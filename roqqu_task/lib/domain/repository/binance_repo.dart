import 'package:roqqu_task/data/data_source.dart';
import 'package:roqqu_task/domain/model/candle_model.dart';
import 'package:roqqu_task/domain/model/order_book_model.dart';
import 'package:roqqu_task/domain/model/ticker_model.dart';

abstract class BinanceRepository {
  Stream<Candle> getKlineStream(String symbol, String interval);
  Stream<Orderbook> getOrderbookStream(String symbol);
  Stream<Ticker> getTickerStream(String symbol);
  Future<void> disconnect();
}

class BinanceRepositoryImpl implements BinanceRepository {
  final BinanceDataSource dataSource;

  BinanceRepositoryImpl({required this.dataSource});

  @override
  Stream<Candle> getKlineStream(String symbol, String interval) {
    dataSource.connectToKlineStream(symbol, interval);
    return dataSource.klineStream;
  }

  @override
  Stream<Orderbook> getOrderbookStream(String symbol) {
    dataSource.connectToDepthStream(symbol);
    return dataSource.depthStream;
  }

  @override
  Stream<Ticker> getTickerStream(String symbol) {
    dataSource.connectToTickerStream(symbol);
    return dataSource.tickerStream;
  }

  @override
  Future<void> disconnect() async {
    await dataSource.disconnect();
  }
}
