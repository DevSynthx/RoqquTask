import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:roqqu_task/core/connection/network_connectivity.dart';
import 'package:roqqu_task/core/errors/exceptions.dart';
import 'package:roqqu_task/domain/model/candle_model.dart';
import 'package:roqqu_task/domain/model/order_book_model.dart';
import 'package:roqqu_task/domain/model/ticker_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum ConnectionState { connected, disconnected, connecting, error }

class BinanceDataSource {
  WebSocketChannel? _klineChannel;
  WebSocketChannel? _depthChannel;
  WebSocketChannel? _tickerChannel;

  final _klineStreamController = StreamController<CandleModel>.broadcast();
  final _depthStreamController = StreamController<OrderbookModel>.broadcast();
  final _tickerStreamController = StreamController<TickerModel>.broadcast();
  int _reconnectAttempt = 0;

  final _connectionStateController =
      StreamController<ConnectionState>.broadcast();

  //-----> Throttling variables
  DateTime? _lastKlineUpdate;
  DateTime? _lastDepthUpdate;
  DateTime? _lastTickerUpdate;

  //------> Store the last used parameters for reconnection
  String? _lastKlineSymbol;
  String? _lastKlineInterval;
  String? _lastDepthSymbol;
  String? _lastTickerSymbol;

  // Configure throttle durations (in milliseconds)
  final int klineThrottleDuration;
  final int depthThrottleDuration;
  final int tickerThrottleDuration;

  final NetworkConnectivityService _networkService =
      NetworkConnectivityService();
  StreamSubscription? _networkSubscription;
  Timer? _reconnectionTimer;

  //-----> Store active connections for reconnection
  bool _klineActive = false;
  bool _depthActive = false;
  bool _tickerActive = false;

  BinanceDataSource({
    this.klineThrottleDuration = 500,
    this.depthThrottleDuration = 300,
    this.tickerThrottleDuration = 200,
  }) {
    _initNetworkMonitoring();
  }

  Stream<CandleModel> get klineStream => _klineStreamController.stream;
  Stream<OrderbookModel> get depthStream => _depthStreamController.stream;
  Stream<TickerModel> get tickerStream => _tickerStreamController.stream;
  Stream<ConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  void _initNetworkMonitoring() {
    _networkService.initialize();

    _networkSubscription = _networkService.status.listen((status) {
      if (status == NetworkStatus.offline) {
        _connectionStateController.add(ConnectionState.disconnected);
        log('Network connectivity lost');

        disconnect();
      } else if (status == NetworkStatus.online) {
        _connectionStateController.add(ConnectionState.connecting);
        log('Network connectivity restored, attempting to reconnect');
        _reconnectActiveStreams();
      }
    });
  }

  void _reconnectActiveStreams() {
    _reconnectionTimer?.cancel();

    _reconnectionTimer = Timer(const Duration(seconds: 1), () async {
      //------> Reconnect all active streams
      if (_klineActive) {
        final symbol = _lastKlineSymbol;
        final interval = _lastKlineInterval;
        if (symbol != null && interval != null) {
          await connectToKlineStream(symbol, interval);
        }
      }

      if (_depthActive) {
        final symbol = _lastDepthSymbol;
        if (symbol != null) {
          await connectToDepthStream(symbol);
        }
      }

      if (_tickerActive) {
        final symbol = _lastTickerSymbol;
        if (symbol != null) {
          await connectToTickerStream(symbol);
        }
      }
    });
  }

  Future<void> connectToKlineStream(String symbol, String interval) async {
    if (!await _checkConnectionPrerequisites(_klineStreamController)) {
      return;
    }

    try {
      _connectionStateController.add(ConnectionState.connecting);
      _klineChannel?.sink.close();
      _lastKlineSymbol = symbol;
      _lastKlineInterval = interval;
      _klineActive = true;

      final wsUrl =
          'wss://stream.binance.com:9443/ws/${symbol.toLowerCase()}@kline_$interval';
      _klineChannel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _klineChannel!.stream.listen(
        (message) {
          try {
            _connectionStateController.add(ConnectionState.connected);
            _resetReconnectAttempts();

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
          _handleWebSocketError(error, _klineStreamController,
              () => connectToKlineStream(symbol, interval));
        },
        onDone: () {
          if (_networkService.currentStatus == NetworkStatus.online) {
            _handleReconnection(() => connectToKlineStream(symbol, interval));
          }
        },
      );
    } catch (e) {
      _connectionStateController.add(ConnectionState.error);
      throw _createWebSocketException(e, 'kline');
    }
  }

  Future<void> connectToDepthStream(String symbol) async {
    if (!await _checkConnectionPrerequisites(_depthStreamController)) {
      return;
    }

    try {
      _connectionStateController.add(ConnectionState.connecting);
      _depthChannel?.sink.close();
      _lastDepthSymbol = symbol;
      _depthActive = true;

      final wsUrl =
          'wss://stream.binance.com:9443/ws/${symbol.toLowerCase()}@depth20@1000ms';
      _depthChannel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _depthChannel!.stream.listen(
        (message) {
          try {
            _connectionStateController.add(ConnectionState.connected);
            _resetReconnectAttempts();

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
          _handleWebSocketError(error, _depthStreamController,
              () => connectToDepthStream(symbol));
        },
        onDone: () {
          if (_networkService.currentStatus == NetworkStatus.online) {
            _handleReconnection(() => connectToDepthStream(symbol));
          }
        },
      );
    } catch (e) {
      _connectionStateController.add(ConnectionState.error);
      throw _createWebSocketException(e, 'depth');
    }
  }

  Future<void> connectToTickerStream(String symbol) async {
    if (!await _checkConnectionPrerequisites(_tickerStreamController)) {
      return;
    }

    try {
      _connectionStateController.add(ConnectionState.connecting);
      _tickerChannel?.sink.close();
      _lastTickerSymbol = symbol;
      _tickerActive = true;

      final wsUrl =
          'wss://stream.binance.com:9443/ws/${symbol.toLowerCase()}@ticker';
      _tickerChannel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _tickerChannel!.stream.listen(
        (message) {
          try {
            _connectionStateController.add(ConnectionState.connected);
            _resetReconnectAttempts();

            //------> Apply throttling
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
          _handleWebSocketError(error, _tickerStreamController,
              () => connectToTickerStream(symbol));
        },
        onDone: () {
          //------> Connection closed, attempt to reconnect if we have internet
          if (_networkService.currentStatus == NetworkStatus.online) {
            _handleReconnection(() => connectToTickerStream(symbol));
          }
        },
      );
    } catch (e) {
      _connectionStateController.add(ConnectionState.error);
      throw _createWebSocketException(e, 'ticker');
    }
  }

  void _handleReconnection(Function() reconnectFunction) {
    final delay = Duration(
        seconds: _reconnectAttempt == 0
            ? 1
            : _reconnectAttempt == 1
                ? 2
                : _reconnectAttempt == 2
                    ? 5
                    : _reconnectAttempt == 3
                        ? 8
                        : 11);

    log('WebSocket disconnected. Attempting to reconnect in ${delay.inSeconds} seconds (attempt ${_reconnectAttempt + 1})');

    //------> Increment reconnect attempt, capping at 4
    if (_reconnectAttempt < 4) {
      _reconnectAttempt++;
    }

    //-----> Handles reconnection
    Future.delayed(delay, () {
      if (_networkService.currentStatus == NetworkStatus.online) {
        reconnectFunction();
      }
    });
  }

  //-----> Handles host resolution
  Future<bool> _canResolveHost(String host) async {
    try {
      final result = await InternetAddress.lookup(host)
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      log('DNS lookup failed: Unable to resolve $host');
      return false;
    } on TimeoutException {
      log('DNS lookup timed out for $host');
      return false;
    } catch (e) {
      log('Error checking host resolution: $e');
      return false;
    }
  }

  //------>  Handles network connectivity and DNS resolution
  Future<bool> _checkConnectionPrerequisites(
      StreamController streamController) async {
    if (_networkService.currentStatus == NetworkStatus.offline) {
      _connectionStateController.add(ConnectionState.error);
      streamController.addError(
          WebSocketException(message: 'No internet connection available'));
      return false;
    }

    final canResolve = await _canResolveHost('stream.binance.com');
    if (!canResolve) {
      _connectionStateController.add(ConnectionState.error);
      streamController.addError(WebSocketException(
          message:
              'Cannot resolve Binance server. Check your network connection.'));
      return false;
    }

    return true;
  }

  //------> Handles WebSocket Error
  void _handleWebSocketError<T>(dynamic error,
      StreamController<T> streamController, Function() reconnectFunction) {
    _connectionStateController.add(ConnectionState.error);

    if (error is WebSocketChannelException) {
      if (error.toString().contains('Failed host lookup') ||
          error.toString().contains('SocketException')) {
        streamController.addError(WebSocketException(
            message:
                'Cannot connect to Binance. DNS resolution failed or network is unavailable.'));
      } else {
        streamController.addError(error);
      }
    } else {
      streamController.addError(error);
    }

    if (_networkService.currentStatus == NetworkStatus.online) {
      _handleReconnection(reconnectFunction);
    }
  }

  //------->  Handles WebSocket exception
  WebSocketException _createWebSocketException(
      dynamic error, String streamType) {
    if (error is SocketException) {
      return WebSocketException(
          message:
              'Network error: Unable to connect to $streamType stream: ${error.message}');
    } else if (error is WebSocketChannelException) {
      if (error.toString().contains('Failed host lookup')) {
        return WebSocketException(
            message:
                'DNS resolution failed: Unable to resolve Binance server address. Check your network connection.');
      } else {
        return WebSocketException(
            message: 'WebSocket error: Unable to connect to Binance');
      }
    } else {
      return WebSocketException(
          message: 'Failed to connect to $streamType stream: $error');
    }
  }

  //-----> Reset reconnection attempts counter when a successful connection is established
  void _resetReconnectAttempts() {
    _reconnectAttempt = 0;
  }

  //------> check network connectivity
  Future<bool> checkConnectivity() async {
    final status = await _networkService.checkConnection();
    return status == NetworkStatus.online;
  }

  Future<void> disconnect() async {
    _klineChannel?.sink.close();
    _depthChannel?.sink.close();
    _tickerChannel?.sink.close();
    _connectionStateController.add(ConnectionState.disconnected);
  }

  Future<void> dispose() async {
    _reconnectionTimer?.cancel();
    _networkSubscription?.cancel();
    await disconnect();
    await _klineStreamController.close();
    await _depthStreamController.close();
    await _tickerStreamController.close();
    await _connectionStateController.close();
  }
}
