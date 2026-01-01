import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class UserService {
  static UserService? _instance;
  static UserService get instance => _instance ??= UserService._();

  UserService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  /// Get user profile by ID
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? username,
    String? fullName,
    String? bio,
    String? avatarUrl,
    String? website,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      final updateData = <String, dynamic>{};
      if (username != null) updateData['username'] = username;
      if (fullName != null) updateData['full_name'] = fullName;
      if (bio != null) updateData['bio'] = bio;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (website != null) updateData['website'] = website;

      if (updateData.isEmpty) return false;

      await _client
          .from('profiles')
          .update(updateData)
          .eq('id', userId);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Search users by username (excludes blocked users)
  Future<List<Map<String, dynamic>>> searchUsers(String query, {int limit = 20}) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) return [];

      // Search users with blocking logic
      final response = await _client
          .from('profiles')
          .select('id, username, full_name, avatar_url, bio')
          .or('username.ilike.%$query%,full_name.ilike.%$query%')
          .neq('id', currentUserId) // Exclude current user
          .limit(limit);

      final users = List<Map<String, dynamic>>.from(response);
      
      // Filter out blocked users
      final filteredUsers = <Map<String, dynamic>>[];
      for (final user in users) {
        final userId = user['id'] as String;
        
        // Check if there's a block relationship (either direction)
        final blockCheck = await _client
            .from('blocks')
            .select('id')
            .or('blocker_id.eq.$currentUserId,blocked_id.eq.$currentUserId')
            .or('blocker_id.eq.$userId,blocked_id.eq.$userId')
            .maybeSingle();
            
        // Only include user if no block relationship exists
        if (blockCheck == null) {
          filteredUsers.add(user);
        }
      }
      
      return filteredUsers;
    } catch (e) {
      return [];
    }
  }

  /// Follow a user
  Future<bool> followUser(String userIdToFollow) async {
    try {
      // Starting followUser
      final currentUserId = _client.auth.currentUser?.id;
      // Current user ID
      
      if (currentUserId == null || currentUserId == userIdToFollow) {
        // Invalid user IDs
        return false;
      }

      // Check if already following to avoid duplicate key error
      final alreadyFollowing = await isFollowing(userIdToFollow);
      if (alreadyFollowing) {
        return true;
      }

      // Insert follow record
      await _client.from('follows').insert({
        'follower_id': currentUserId,
        'following_id': userIdToFollow,
      });

      return true;
    } catch (e) {
      // Error in followUser
      return false;
    }
  }

  /// Unfollow a user
  Future<bool> unfollowUser(String userIdToUnfollow) async {
    try {
      // Starting unfollowUser
      final currentUserId = _client.auth.currentUser?.id;
      // Current user ID
      
      if (currentUserId == null) {
        // No current user
        return false;
      }

      // First, try to send notification via backend API (if needed for unfollow)
      // For now, we'll proceed with database operation directly
      // You can add notification logic here if needed for unfollow events

      try {
        // Deleting follow record
        await _client
            .from('follows')
            .delete()
            .eq('follower_id', currentUserId)
            .eq('following_id', userIdToUnfollow);
        // Follow record deleted successfully
        return true;
      } catch (dbError) {
        // Database error when deleting follow record
        return false;
      }
    } catch (e) {
      // Error in unfollowUser
      return false;
    }
  }

  /// Check if current user is following another user
  Future<bool> isFollowing(String userId) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        // No current user
        return false;
      }

      // Checking if following user
      
      final response = await _client
          .from('follows')
          .select('id')
          .eq('follower_id', currentUserId)
          .eq('following_id', userId)
          .maybeSingle();

      final result = response != null;
      // Result of follow check
      
      return result;
    } catch (e) {
      // Error checking follow status
      return false;
    }
  }

  /// Get followers list with follow status
  Future<List<Map<String, dynamic>>> getFollowers(String userId) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      
      final response = await _client
          .from('follows')
          .select('''
            follower_id,
            profiles!follows_follower_id_fkey(
              id,
              username,
              full_name,
              avatar_url,
              bio
            )
          ''')
          .eq('following_id', userId);

      // Get ALL follow statuses in ONE query
      if (currentUserId != null && response.isNotEmpty) {
        // Get all follower IDs
        final followerIds = response
            .map((item) => item['profiles']?['id'] as String?)
            .where((id) => id != null)
            .toList();
        
        // Batch check - get all follows in one query
        final followChecks = await _client
            .from('follows')
            .select('following_id')
            .eq('follower_id', currentUserId)
            .inFilter('following_id', followerIds);
        
        // Create set of followed user IDs
        final followedIds = followChecks
            .map((f) => f['following_id'] as String)
            .toSet();
        
        // Add is_following to each profile
        for (final item in response) {
          final profile = item['profiles'];
          if (profile != null) {
            final followerId = profile['id'] as String;
            profile['is_following'] = followedIds.contains(followerId);
          }
        }
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// Get following list with follow status  
  Future<List<Map<String, dynamic>>> getFollowing(String userId) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      
      final response = await _client
          .from('follows')
          .select('''
            following_id,
            profiles!follows_following_id_fkey(
              id,
              username,
              full_name,
              avatar_url,
              bio
            )
          ''')
          .eq('follower_id', userId);

      // Get ALL follow statuses in ONE query
      if (currentUserId != null && response.isNotEmpty) {
        // Get all following IDs
        final followingIds = response
            .map((item) => item['profiles']?['id'] as String?)
            .where((id) => id != null)
            .toList();
        
        // Batch check - get all follows in one query
        final followChecks = await _client
            .from('follows')
            .select('following_id')
            .eq('follower_id', currentUserId)
            .inFilter('following_id', followingIds);
        
        // Create set of followed user IDs
        final followedIds = followChecks
            .map((f) => f['following_id'] as String)
            .toSet();
        
        // Add is_following to each profile
        for (final item in response) {
          final profile = item['profiles'];
          if (profile != null) {
            final followingId = profile['id'] as String;
            profile['is_following'] = followedIds.contains(followingId);
          }
        }
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// Get user stats (followers count, following count, posts count)
  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      // Get followers with profile data to deduplicate by user ID
      final followersResponse = await _client
          .from('follows')
          .select('''
            follower_id,
            profiles!follows_follower_id_fkey(id)
          ''')
          .eq('following_id', userId);

      // Deduplicate followers by follower_id
      final uniqueFollowerIds = <String>{};
      for (final item in followersResponse) {
        final profile = item['profiles'];
        if (profile != null && profile['id'] != null) {
          uniqueFollowerIds.add(profile['id'] as String);
        }
      }

      // Get following with profile data to deduplicate by user ID
      final followingResponse = await _client
          .from('follows')
          .select('''
            following_id,
            profiles!follows_following_id_fkey(id)
          ''')
          .eq('follower_id', userId);

      // Deduplicate following by following_id
      final uniqueFollowingIds = <String>{};
      for (final item in followingResponse) {
        final profile = item['profiles'];
        if (profile != null && profile['id'] != null) {
          uniqueFollowingIds.add(profile['id'] as String);
        }
      }

      final postsResponse = await _client
          .from('posts')
          .select('id')
          .eq('user_id', userId);

      return {
        'followers': uniqueFollowerIds.length,
        'following': uniqueFollowingIds.length,
        'posts': postsResponse.length,
      };
    } catch (e) {
      return {
        'followers': 0,
        'following': 0,
        'posts': 0,
      };
    }
  }
}
