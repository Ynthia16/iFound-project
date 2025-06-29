import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ConnectionProvider extends ChangeNotifier {
  bool _isConnected = true;
  bool _isFirebaseConnected = true;
  StreamSubscription? _connectivitySubscription;

  bool get isConnected => _isConnected;
  bool get isFirebaseConnected => _isFirebaseConnected;

  ConnectionProvider() {
    _initConnectivity();
  }

  void _initConnectivity() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((result) {
      // Handle both List<ConnectivityResult> and ConnectivityResult
      _isConnected = result.isNotEmpty && result.first != ConnectivityResult.none;
          notifyListeners();
    });
  }

  void setFirebaseConnectionStatus(bool connected) {
    _isFirebaseConnected = connected;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}