import 'package:shared_preferences/shared_preferences.dart';

class GuestUserManager {
  static const String _prefsKey = 'is_guest_user';
  static const String _guestModeKey = 'guest_mode_enabled';
  
  static GuestUserManager? _instance;
  static GuestUserManager get instance {
    _instance ??= GuestUserManager._();
    return _instance!;
  }
  
  GuestUserManager._();
  
  /// Check if user has chosen to continue as guest
  Future<bool> isGuestUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKey) ?? false;
  }
  
  /// Set guest user preference
  Future<void> setGuestUser(bool isGuest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, isGuest);
  }
  
  /// Enable/disable guest mode entirely
  Future<void> setGuestModeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestModeKey, enabled);
  }
  
  /// Check if guest mode is enabled
  Future<bool> isGuestModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_guestModeKey) ?? true; // Default to enabled
  }
  
  /// Clear guest user preference
  Future<void> clearGuestPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
  
  /// Mark user as authenticated (clear guest status)
  Future<void> markAsAuthenticated() async {
    await setGuestUser(false);
  }
}