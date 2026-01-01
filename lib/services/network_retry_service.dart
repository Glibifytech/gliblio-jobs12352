import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkRetryService {
  static final NetworkRetryService _instance = NetworkRetryService._internal();
  factory NetworkRetryService() => _instance;
  NetworkRetryService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final List<VoidCallback> _retryCallbacks = [];
  bool _isConnected = true;

  /// Initialize the network retry service
  Future<void> initialize() async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _isConnected = !result.contains(ConnectivityResult.none);
    
    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    

  }

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;
    _isConnected = !results.contains(ConnectivityResult.none);
    
    // If we just got connected after being disconnected, retry all callbacks
    if (!wasConnected && _isConnected) {
      _executeRetryCallbacks();
    }
  }

  /// Register a callback to be executed when network is restored
  void registerRetryCallback(VoidCallback callback) {
    if (!_retryCallbacks.contains(callback)) {
      _retryCallbacks.add(callback);
    }
  }

  /// Unregister a retry callback
  void unregisterRetryCallback(VoidCallback callback) {
    _retryCallbacks.remove(callback);
  }

  /// Execute all retry callbacks
  void _executeRetryCallbacks() {
    for (final callback in _retryCallbacks) {
      try {
        callback();
      } catch (e) {
        // Silent fail
      }
    }
  }

  /// Check if currently connected to network
  bool get isConnected => _isConnected;

  /// Execute a function with automatic retry on network restore
  Future<T?> executeWithRetry<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    try {
      if (!_isConnected) {
        return null;
      }
      
      return await operation();
    } catch (e) {
      // Register for retry if it looks like a network error
      if (_isNetworkError(e)) {
        registerRetryCallback(() async {
          try {
            await operation();
          } catch (retryError) {
            // Silent fail
          }
        });
      }
      
      rethrow;
    }
  }

  /// Check if an error is likely network-related
  bool _isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
           errorString.contains('connection') ||
           errorString.contains('timeout') ||
           errorString.contains('unreachable') ||
           errorString.contains('socket') ||
           errorString.contains('failed host lookup');
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _retryCallbacks.clear();
  }
}
