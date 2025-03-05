import 'dart:developer';

import 'package:roqqu_task/data/data_source.dart';
import 'package:roqqu_task/domain/model/candle_model.dart';
import 'package:roqqu_task/domain/model/order_book_model.dart';
import 'package:roqqu_task/domain/model/ticker_model.dart';

abstract class BinanceRepository {
  Stream<Candle> getKlineStream(String symbol, String interval);
  Stream<Orderbook> getOrderbookStream(String symbol);
  Stream<Ticker> getTickerStream(String symbol);
  // Stream<ConnectionState> get connectionStateStream;
  Future<void> disconnect();
}

class BinanceRepositoryImpl implements BinanceRepository {
  final BinanceDataSource dataSource;

  BinanceRepositoryImpl({required this.dataSource});

  @override
  Stream<Candle> getKlineStream(String symbol, String interval) {
    try {
      dataSource.connectToKlineStream(symbol, interval).catchError((error) {
        log('Error connecting to kline stream: $error');
      });

      return dataSource.klineStream.handleError((error) {
        log('Handled error in kline stream: $error');
      });
    } catch (e) {
      log('Synchronous error in getKlineStream: $e');
      return Stream.error(e);
    }
  }

  @override
  Stream<Orderbook> getOrderbookStream(String symbol) {
    try {
      dataSource.connectToDepthStream(symbol).catchError((error) {
        log('Error connecting to depth stream: $error');
      });

      return dataSource.depthStream.handleError((error) {
        log('Handled error in depth stream: $error');
      });
    } catch (e) {
      log('Synchronous error in getOrderbookStream: $e');
      return Stream.error(e);
    }
  }

  @override
  Stream<Ticker> getTickerStream(String symbol) {
    try {
      dataSource.connectToTickerStream(symbol).catchError((error) {
        log('Error connecting to ticker stream: $error');
      });

      return dataSource.tickerStream.handleError((error) {
        log('Handled error in ticker stream: $error');
      });
    } catch (e) {
      log('Synchronous error in getTickerStream: $e');
      return Stream.error(e);
    }
  }

  // @override
  // Stream<ConnectionState> get connectionStateStream =>
  //     dataSource.connectionStateStream;

  @override
  Future<void> disconnect() async {
    try {
      await dataSource.disconnect();
    } catch (e) {
      log('Error during disconnect: $e');
    }
  }
}
