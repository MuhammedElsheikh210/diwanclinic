import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {

  final Connectivity _connectivity = Connectivity();

  final StreamController<bool> _connectionController =
  StreamController.broadcast();

  Stream<bool> get onConnectionChange => _connectionController.stream;

  void startListening() {
    _connectivity.onConnectivityChanged.listen((result) {
      final isOnline = result != ConnectivityResult.none;
      _connectionController.add(isOnline);
    });
  }

  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void dispose() {
    _connectionController.close();
  }
}