import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';
import './guest_user_manager.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  AuthService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Get current session
  Session? get currentSession => _client.auth.currentSession;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Auth state stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    String? username,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          if (fullName != null) 'full_name': fullName,
          if (username != null) 'username': username,
        },
      );
      
      // Clear guest status when user signs up
      await GuestUserManager.instance.markAsAuthenticated();
      
      return response;
    } catch (error) {
      throw Exception('Sign up failed: $error');
    }
  }

  /// Sign in with OAuth
  Future<bool> signInWithOAuth(OAuthProvider provider) async {
    try {
      return await _client.auth.signInWithOAuth(
        provider,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );
    } catch (error) {
      throw Exception('OAuth sign in failed: $error');
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      // Clear guest status when user logs in
      await GuestUserManager.instance.markAsAuthenticated();
      
      return response;
    } catch (error) {
      throw Exception('Sign in failed: $error');
    }
  }

  /// Sign in with OTP (Phone or Email)
  Future<void> signInWithOTP({
    String? email,
    String? phone,
  }) async {
    try {
      if (email != null) {
        await _client.auth.signInWithOtp(email: email);
      } else if (phone != null) {
        await _client.auth.signInWithOtp(phone: phone);
      } else {
        throw Exception('Either email or phone must be provided');
      }
    } catch (error) {
      throw Exception('OTP request failed: $error');
    }
  }

  /// Verify OTP
  Future<AuthResponse> verifyOTP({
    required String token,
    required OtpType type,
    String? email,
    String? phone,
  }) async {
    try {
      final response = await _client.auth.verifyOTP(
        token: token,
        type: type,
        email: email,
        phone: phone,
      );
      return response;
    } catch (error) {
      throw Exception('OTP verification failed: $error');
    }
  }

  /// Resend OTP
  Future<void> resendOTP({
    String? email,
    String? phone,
    required OtpType type,
  }) async {
    try {
      await _client.auth.resend(
        type: type,
        email: email,
        phone: phone,
      );
    } catch (error) {
      throw Exception('Resend OTP failed: $error');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      // Clear guest status when signing out
      await GuestUserManager.instance.clearGuestPreference();
    } catch (error) {
      throw Exception('Sign out failed: $error');
    }
  }

  /// Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('Password reset failed: $error');
    }
  }

  /// Update user password
  Future<UserResponse> updatePassword({required String password}) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: password),
      );
      return response;
    } catch (error) {
      throw Exception('Password update failed: $error');
    }
  }

  /// Change password with old password verification (for settings)
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = currentUser;
      if (user?.email == null) {
        throw Exception('User not authenticated');
      }

      // First verify old password by signing in
      final response = await _client.auth.signInWithPassword(
        email: user!.email!,
        password: oldPassword,
      );

      if (response.user == null) {
        throw Exception('Current password is incorrect');
      }

      // If verification successful, update to new password
      await updatePassword(password: newPassword);
    } catch (error) {
      throw Exception('Password change failed: $error');
    }
  }

  /// Update user profile
  Future<UserResponse> updateProfile({
    String? fullName,
    String? username,
    String? avatarUrl,
  }) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(
          data: {
            if (fullName != null) 'full_name': fullName,
            if (username != null) 'username': username,
            if (avatarUrl != null) 'avatar_url': avatarUrl,
          },
        ),
      );
      return response;
    } catch (error) {
      throw Exception('Profile update failed: $error');
    }
  }

  /// Get user profile from database
  Future<Map<String, dynamic>?> getUserProfile([String? userId]) async {
    try {
      final uid = userId ?? currentUser?.id;
      if (uid == null) return null;

      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();

      return response;
    } catch (error) {
      throw Exception('Failed to get user profile: $error');
    }
  }

  /// Update user profile in database
  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    String? fullName,
    String? username,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (fullName != null) updateData['full_name'] = fullName;
      if (username != null) updateData['username'] = username;
      if (bio != null) updateData['bio'] = bio;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('user_profiles')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to update user profile: $error');
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      // Delete user profile from database
      await _client.from('user_profiles').delete().eq('id', user.id);

      // Sign out user
      await signOut();
    } catch (error) {
      throw Exception('Account deletion failed: $error');
    }
  }
}
