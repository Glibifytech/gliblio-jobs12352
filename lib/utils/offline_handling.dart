import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Utility class to handle offline scenarios and provide user-friendly error messages
/// Prevents exposing Supabase URLs/keys to users during network failures
class OfflineHandler {
  static final OfflineHandler _instance = OfflineHandler._internal();
  factory OfflineHandler() => _instance;
  OfflineHandler._internal();

  /// Check if device has network connectivity
  static Future<bool> hasNetworkConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return false;
      }

      // Additional check with actual network request
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get user-friendly error message for authentication failures
  static String getAuthErrorMessage(dynamic error) {
    // First check for network connectivity
    return _processAuthError(error);
  }

  /// Get user-friendly error message for general network errors
  static String getNetworkErrorMessage(dynamic error) {
    return _processNetworkError(error);
  }

  /// Process authentication-specific errors
  static String _processAuthError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Network-related errors
    if (_isNetworkError(errorString)) {
      return 'No internet connection. Please check your network and try again.';
    }

    // Supabase-specific auth errors (hide technical details)
    if (errorString.contains('invalid_grant') || 
        errorString.contains('invalid_credentials') ||
        errorString.contains('invalid email or password')) {
      return 'Invalid email or password. Please check your credentials and try again.';
    }

    if (errorString.contains('signup_disabled')) {
      return 'Account registration is temporarily disabled. Please try again later.';
    }

    if (errorString.contains('email_address_invalid')) {
      return 'Please enter a valid email address.';
    }

    if (errorString.contains('password') && errorString.contains('weak')) {
      return 'Password is too weak. Please use at least 8 characters with numbers and letters.';
    }

    if (errorString.contains('email_already_exists') || 
        errorString.contains('user_already_registered')) {
      return 'An account with this email already exists. Try signing in instead.';
    }

    if (errorString.contains('confirmation_required') || 
        errorString.contains('email_not_confirmed')) {
      return 'Please check your email and confirm your account before signing in.';
    }

    if (errorString.contains('too_many_requests') || 
        errorString.contains('rate_limit')) {
      return 'Too many attempts. Please wait a few minutes and try again.';
    }

    if (errorString.contains('token') && errorString.contains('expired')) {
      return 'Your session has expired. Please sign in again.';
    }

    // Database/Server errors (hide technical details)
    if (errorString.contains('postgres') || 
        errorString.contains('database') ||
        errorString.contains('supabase') ||
        errorString.contains('rpc') ||
        errorString.contains('status code 500') ||
        errorString.contains('internal server error')) {
      return 'Service temporarily unavailable. Please try again in a few moments.';
    }

    // Timeout errors
    if (errorString.contains('timeout') || 
        errorString.contains('connection timeout')) {
      return 'Connection timeout. Please check your internet and try again.';
    }

    // Generic fallback for unknown errors
    return 'Something went wrong. Please try again later.';
  }

  /// Process general network errors
  static String _processNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (_isNetworkError(errorString)) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (errorString.contains('timeout')) {
      return 'Request timeout. Please try again.';
    }

    if (errorString.contains('server') || errorString.contains('503') || errorString.contains('502')) {
      return 'Service temporarily unavailable. Please try again later.';
    }

    return 'Network error. Please check your connection and try again.';
  }

  /// Check if error is network-related
  static bool _isNetworkError(String errorString) {
    final networkKeywords = [
      'network',
      'connection',
      'internet',
      'offline',
      'no connectivity',
      'unreachable',
      'dns',
      'socket',
      'failed host lookup',
      'connection refused',
      'connection reset',
      'no route to host',
      'network is unreachable',
    ];

    return networkKeywords.any((keyword) => errorString.contains(keyword));
  }
}