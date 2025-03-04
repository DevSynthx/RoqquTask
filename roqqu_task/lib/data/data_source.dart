import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:roqqu_task/core/errors/exceptions.dart';
import 'package:roqqu_task/domain/model/candle_model.dart';
import 'package:roqqu_task/domain/model/order_book_model.dart';
import 'package:roqqu_task/domain/model/ticker_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class BinanceDataSource {
  WebSocketChannel? _klineChannel;
  WebSocketChannel? _depthChannel;
  WebSocketChannel? _tickerChannel;

  final _klineStreamController = StreamController<CandleModel>.broadcast();
  final _depthStreamController = StreamController<OrderbookModel>.broadcast();
  final _tickerStreamController = StreamController<TickerModel>.broadcast();

  // Throttling variables
  DateTime? _lastKlineUpdate;
  DateTime? _lastDepthUpdate;
  DateTime? _lastTickerUpdate;

  // Configure throttle durations (in milliseconds)
  final int klineThrottleDuration;
  final int depthThrottleDuration;
  final int tickerThrottleDuration;

  BinanceDataSource({
    this.klineThrottleDuration = 1000, // 1 second
    this.depthThrottleDuration = 500, // 500 milliseconds
    this.tickerThrottleDuration = 1000, // 1 second
  });

  Stream<CandleModel> get klineStream => _klineStreamController.stream;
  Stream<OrderbookModel> get depthStream => _depthStreamController.stream;
  Stream<TickerModel> get tickerStream => _tickerStreamController.stream;

  Future<void> connectToKlineStream(String symbol, String interval) async {
    try {
      _klineChannel?.sink.close();

      final wsUrl =
          'wss://stream.binance.com:9443/ws/${symbol.toLowerCase()}@kline_$interval';
      _klineChannel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _klineChannel!.stream.listen(
        (message) {
          try {
            // Apply throttling
            final now = DateTime.now();
            if (_lastKlineUpdate == null ||
                now.difference(_lastKlineUpdate!).inMilliseconds >=
                    klineThrottleDuration) {
              final data = jsonDecode(message);
              log("message: $data");
              final candle = CandleModel.fromWebSocket(data);
              _klineStreamController.add(candle);

              _lastKlineUpdate = now;
            }
          } catch (e) {
            _klineStreamController.addError(e);
          }
        },
        onError: (error) {
          _klineStreamController.addError(error);
        },
        onDone: () {
          // Attempt to reconnect
          Future.delayed(const Duration(seconds: 5), () {
            connectToKlineStream(symbol, interval);
          });
        },
      );
    } catch (e) {
      throw WebSocketException(
          message: 'Failed to connect to kline stream: $e');
    }
  }

  Future<void> connectToDepthStream(String symbol) async {
    try {
      _depthChannel?.sink.close();

      // You can also change the update frequency here from 100ms to a higher value
      final wsUrl =
          'wss://stream.binance.com:9443/ws/${symbol.toLowerCase()}@depth20@1000ms';
      _depthChannel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _depthChannel!.stream.listen(
        (message) {
          try {
            // Apply throttling
            final now = DateTime.now();
            if (_lastDepthUpdate == null ||
                now.difference(_lastDepthUpdate!).inMilliseconds >=
                    depthThrottleDuration) {
              final data = jsonDecode(message);
              final orderbook = OrderbookModel.fromWebSocket(data);
              _depthStreamController.add(orderbook);

              _lastDepthUpdate = now;
            }
          } catch (e) {
            _depthStreamController.addError(e);
          }
        },
        onError: (error) {
          _depthStreamController.addError(error);
        },
        onDone: () {
          // Attempt to reconnect
          Future.delayed(const Duration(seconds: 2), () {
            connectToDepthStream(symbol);
          });
        },
      );
    } catch (e) {
      throw WebSocketException(
          message: 'Failed to connect to depth stream: $e');
    }
  }

  Future<void> connectToTickerStream(String symbol) async {
    try {
      _tickerChannel?.sink.close();

      final wsUrl =
          'wss://stream.binance.com:9443/ws/${symbol.toLowerCase()}@ticker';
      _tickerChannel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _tickerChannel!.stream.listen(
        (message) {
          try {
            // Apply throttling
            final now = DateTime.now();
            if (_lastTickerUpdate == null ||
                now.difference(_lastTickerUpdate!).inMilliseconds >=
                    tickerThrottleDuration) {
              final data = jsonDecode(message);
              final ticker = TickerModel.fromWebSocket(data);
              _tickerStreamController.add(ticker);

              _lastTickerUpdate = now;
            }
          } catch (e) {
            _tickerStreamController.addError(e);
          }
        },
        onError: (error) {
          _tickerStreamController.addError(error);
        },
        onDone: () {
          // Attempt to reconnect
          Future.delayed(const Duration(seconds: 2), () {
            connectToTickerStream(symbol);
          });
        },
      );
    } catch (e) {
      throw WebSocketException(
          message: 'Failed to connect to ticker stream: $e');
    }
  }

  Future<void> disconnect() async {
    _klineChannel?.sink.close();
    _depthChannel?.sink.close();
    _tickerChannel?.sink.close();
  }

  Future<void> dispose() async {
    await disconnect();
    await _klineStreamController.close();
    await _depthStreamController.close();
    await _tickerStreamController.close();
  }
}
