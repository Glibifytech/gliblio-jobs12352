
/// Service to manage shimmer loading state
/// Shows shimmer only on first app load, not on subsequent navigations
class ShimmerService {
  static final ShimmerService _instance = ShimmerService._internal();
  factory ShimmerService() => _instance;
  ShimmerService._internal();

  static ShimmerService get instance => _instance;

  // Track if this is the first time loading screens
  bool _hasLoadedHomeFeedOnce = false;
  bool _hasLoadedMessagesOnce = false;
  
  // Track if we're currently showing shimmer
  bool _isShowingShimmer = false;

  /// Check if we should show shimmer for home feed
  bool get shouldShowShimmerForHomeFeed {
    if (_hasLoadedHomeFeedOnce) {
      return false;
    }
    
    return true;
  }

  /// Check if shimmer is currently being shown
  bool get isShowingShimmer => _isShowingShimmer;

  /// Mark that shimmer is now being shown
  void startShimmer() {
    _isShowingShimmer = true;
  }

  /// Mark that shimmer should stop and home feed has been loaded
  void stopShimmer() {
    _isShowingShimmer = false;
    _hasLoadedHomeFeedOnce = true;
  }

  /// Reset the service (useful for testing or logout)
  void reset() {
    _hasLoadedHomeFeedOnce = false;
    _hasLoadedMessagesOnce = false;
    _isShowingShimmer = false;
  }

  /// Check if we should show shimmer for messages screen
  bool get shouldShowShimmerForMessages {
    if (_hasLoadedMessagesOnce) {
      return false;
    }
    return true;
  }

  /// Mark that messages have been loaded once
  void markMessagesLoaded() {
    _hasLoadedMessagesOnce = true;
  }

  /// Check if we should show shimmer for any screen (can be extended)
  bool shouldShowShimmerForScreen(String screenName) {
    switch (screenName) {
      case 'home':
        return shouldShowShimmerForHomeFeed;
      case 'messages':
        return shouldShowShimmerForMessages;
      case 'profile':
        // Profile screen doesn't need shimmer after first load
        return false;
      case 'search':
        // Search screen doesn't need shimmer after first load
        return false;
      default:
        return false;
    }
  }
}
