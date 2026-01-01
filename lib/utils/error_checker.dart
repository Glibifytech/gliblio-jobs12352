import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorChecker {
  static const Map<String, String> _errorMessages = {
    // Auth errors
    'email_already_in_use': 'This email is already registered. Please use a different email or try signing in.',
    'weak_password': 'Password is too weak. Please use at least 8 characters with numbers and letters.',
    'invalid_email': 'Please enter a valid email address.',
    'user_not_found': 'No account found with this email. Please check your email or sign up.',
    'wrong_password': 'Incorrect password. Please try again.',
    'too_many_requests': 'Too many attempts. Please wait a moment and try again.',
    
    // Database errors
    'username_already_exists': 'This username is already taken. Please choose a different username.',
    'profile_creation_failed': 'Failed to create your profile. Please try again.',
    'network_error': 'Network connection error. Please check your internet and try again.',
    'database_error': 'Server error occurred. Please try again in a moment.',
    
    // Storage errors
    'storage_unauthorized': 'Unable to upload image. Please try again or contact support.',
    'storage_permission_denied': 'Permission denied. Please check your camera/photos permissions.',
    'image_too_large': 'Image is too large. Please choose a smaller image.',
    'invalid_image_format': 'Invalid image format. Please use JPG, PNG, or WEBP.',
    'storage_quota_exceeded': 'Storage limit reached. Please delete some images and try again.',
    'upload_failed': 'Upload failed. Please check your connection and try again.',
    
    // General errors
    'unexpected_failure': 'Something went wrong. Please try again.',
    'validation_error': 'Please check your information and try again.',
    'permission_denied': 'Permission denied. Please contact support.',
  };

  /// Checks if a username is available before signup
  static Future<bool> isUsernameAvailable(String username) async {
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('username')
          .eq('username', username.toLowerCase())
          .maybeSingle();
      
      return response == null;
    } catch (e) {
      // If we can't check, assume it's available to not block signup
      return true;
    }
  }

  /// Validates username format
  static String? validateUsername(String username) {
    if (username.isEmpty) {
      return 'Username is required';
    }
    
    if (username.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    
    if (username.length > 20) {
      return 'Username must be less than 20 characters';
    }
    
    // Only allow letters, numbers, and underscores
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    
    // Must start with a letter
    if (!RegExp(r'^[a-zA-Z]').hasMatch(username)) {
      return 'Username must start with a letter';
    }
    
    return null;
  }

  /// Validates email format
  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email is required';
    }
    
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Validates password strength
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    if (!RegExp(r'(?=.*[a-zA-Z])(?=.*[0-9])').hasMatch(password)) {
      return 'Password must contain both letters and numbers';
    }
    
    return null;
  }

  /// Validates password confirmation
  static String? validatePasswordConfirmation(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  /// Converts technical errors to user-friendly messages
  static String getErrorMessage(dynamic error) {
    String errorString = error.toString().toLowerCase();
    
    // Handle Supabase Auth errors
    if (error is AuthException) {
      switch (error.message.toLowerCase()) {
        case 'user already registered':
        case 'email already in use':
          return _errorMessages['email_already_in_use']!;
        case 'invalid email':
          return _errorMessages['invalid_email']!;
        case 'weak password':
          return _errorMessages['weak_password']!;
        case 'user not found':
          return _errorMessages['user_not_found']!;
        case 'invalid credentials':
        case 'wrong password':
          return _errorMessages['wrong_password']!;
        case 'too many requests':
          return _errorMessages['too_many_requests']!;
        default:
          return _errorMessages['unexpected_failure']!;
      }
    }
    
    // Handle PostgreSQL/Database errors
    if (error is PostgrestException) {
      String message = error.message.toLowerCase();
      
      if (message.contains('duplicate key') && message.contains('username')) {
        return _errorMessages['username_already_exists']!;
      }
      
      if (message.contains('foreign key') || message.contains('violates')) {
        return _errorMessages['profile_creation_failed']!;
      }
      
      if (message.contains('permission denied') || message.contains('unauthorized')) {
        return _errorMessages['permission_denied']!;
      }
      
      return _errorMessages['database_error']!;
    }
    
    // Handle network errors
    if (errorString.contains('network') || 
        errorString.contains('connection') || 
        errorString.contains('timeout')) {
      return _errorMessages['network_error']!;
    }
    
    // Handle specific error patterns from your screenshot
    if (errorString.contains('unexpected_failure') || 
        errorString.contains('data base error saving new user')) {
      return _errorMessages['database_error']!;
    }
    
    if (errorString.contains('authretryablefetchexception')) {
      return _errorMessages['network_error']!;
    }
    
    // Default fallback
    return _errorMessages['unexpected_failure']!;
  }

  /// Comprehensive signup validation
  static Future<SignupValidationResult> validateSignupData({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    String? fullName,
  }) async {
    List<String> errors = [];
    
    // Validate username format
    String? usernameError = validateUsername(username);
    if (usernameError != null) {
      errors.add(usernameError);
    } else {
      // Check username availability
      bool isAvailable = await isUsernameAvailable(username);
      if (!isAvailable) {
        errors.add(_errorMessages['username_already_exists']!);
      }
    }
    
    // Validate email
    String? emailError = validateEmail(email);
    if (emailError != null) {
      errors.add(emailError);
    }
    
    // Validate password
    String? passwordError = validatePassword(password);
    if (passwordError != null) {
      errors.add(passwordError);
    }
    
    // Validate password confirmation
    String? confirmError = validatePasswordConfirmation(password, confirmPassword);
    if (confirmError != null) {
      errors.add(confirmError);
    }
    
    // Validate full name if provided
    if (fullName != null && fullName.isNotEmpty) {
      if (fullName.length < 2) {
        errors.add('Name must be at least 2 characters long');
      }
      if (fullName.length > 50) {
        errors.add('Name must be less than 50 characters');
      }
    }
    
    return SignupValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Real-time username checker for TextField
  static Future<String?> checkUsernameRealTime(String username) async {
    // First check format
    String? formatError = validateUsername(username);
    if (formatError != null) {
      return formatError;
    }
    
    // Then check availability
    bool isAvailable = await isUsernameAvailable(username);
    if (!isAvailable) {
      return 'Username is already taken';
    }
    
    return null; // Username is valid and available
  }
}

class SignupValidationResult {
  final bool isValid;
  final List<String> errors;
  
  SignupValidationResult({
    required this.isValid,
    required this.errors,
  });
  
  String get firstError => errors.isNotEmpty ? errors.first : '';
  String get allErrors => errors.join('\n');
}
