/// Simple in-memory cache for user profiles with time-based expiration
class UserProfileCache {
  static final UserProfileCache _instance = UserProfileCache._internal();
  factory UserProfileCache() => _instance;
  UserProfileCache._internal();

  Map<String, dynamic>? _cachedProfile;
  DateTime? _lastFetchTime;
  final int _cacheDurationMinutes = 5; // Cache for 5 minutes

  /// Get cached profile if still valid
  Map<String, dynamic>? get profile {
    if (_cachedProfile == null || _lastFetchTime == null) return null;
    
    // Check if cache is still valid (within duration)
    if (DateTime.now().difference(_lastFetchTime!).inMinutes <= _cacheDurationMinutes) {
      return _cachedProfile;
    } else {
      // Expired cache
      clear();
      return null;
    }
  }
  
  bool get hasCache => _cachedProfile != null && _lastFetchTime != null;

  void setProfile(Map<String, dynamic> profile) {
    _cachedProfile = profile;
    _lastFetchTime = DateTime.now();
  }

  void clear() {
    _cachedProfile = null;
    _lastFetchTime = null;
  }
}
