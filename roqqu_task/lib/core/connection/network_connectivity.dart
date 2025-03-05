import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

enum NetworkStatus { online, offline, unknown }

class NetworkConnectivityService {
  static final NetworkConnectivityService _instance =
      NetworkConnectivityService._internal();
  factory NetworkConnectivityService() => _instance;
  NetworkConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  final _networkStatusController = StreamController<NetworkStatus>.broadcast();

  NetworkStatus _currentStatus = NetworkStatus.unknown;

  StreamSubscription? _connectivitySubscription;

  Stream<NetworkStatus> get status => _networkStatusController.stream;

  NetworkStatus get currentStatus => _currentStatus;

  bool _initialized = false;

  void initialize() {
    if (_initialized) return;

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((_) => _checkConnectivity());

    _checkConnectivity();
    _initialized = true;
  }

  Future<void> _checkConnectivity() async {
    NetworkStatus status;

    try {
      final connectivityResults = await _connectivity.checkConnectivity();

      if (connectivityResults.isEmpty ||
          connectivityResults.contains(ConnectivityResult.none)) {
        status = NetworkStatus.offline;
      } else {
        try {
          final result = await InternetAddress.lookup('google.com')
              .timeout(const Duration(seconds: 5));
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            status = NetworkStatus.online;
          } else {
            status = NetworkStatus.offline;
          }
        } on SocketException catch (_) {
          status = NetworkStatus.offline;
        } on TimeoutException catch (_) {
          status = NetworkStatus.offline;
        }
      }
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      status = NetworkStatus.unknown;
    }

    if (_currentStatus != status) {
      _currentStatus = status;
      _networkStatusController.add(status);
      debugPrint('Network status changed: $_currentStatus');
    }
  }

  Future<NetworkStatus> checkConnection() async {
    await _checkConnectivity();
    return _currentStatus;
  }

  // Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _networkStatusController.close();
  }
}
