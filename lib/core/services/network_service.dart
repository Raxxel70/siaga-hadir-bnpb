import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStreamController = StreamController<bool>.broadcast();

  Stream<bool> get onConnectionChanged => _connectionStreamController.stream;

  NetworkService() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final isConnected = results.any((result) => result != ConnectivityResult.none);
      _connectionStreamController.add(isConnected);
    });
  }

  Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }

  void dispose() {
    _connectionStreamController.close();
  }
}
