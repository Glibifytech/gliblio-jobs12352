import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../utils/offline_handling.dart';
import './widgets/custom_text_field.dart';
// import './widgets/social_login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService.instance.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (response.user != null) {
          // Check if user needs email verification
          if (response.user!.emailConfirmedAt == null) {
            // User is not verified, redirect to OTP screen
            HapticFeedback.lightImpact();
            Navigator.pushReplacementNamed(
              context, 
              '/otp-verification',
              arguments: {
                'email': _emailController.text.trim(),
                'type': 'signin',
              },
            );
          } else {
            // User is verified, go to home screen
            HapticFeedback.lightImpact();
            Navigator.pushReplacementNamed(context, '/home-screen');
          }
        } else {
          throw Exception('Authentication failed - please try again');
        }
      }
    } catch (error) {
      if (mounted) {
        // Check if it's an email not confirmed error
        if (error.toString().contains('email_not_confirmed') || 
            error.toString().contains('Email not confirmed') ||
            error.toString().contains('confirm your email') ||
            error.toString().contains('check your email')) {
          // Redirect to OTP verification screen
          HapticFeedback.lightImpact();
          Navigator.pushReplacementNamed(
            context, 
            '/otp-verification',
            arguments: {
              'email': _emailController.text.trim(),
              'type': 'signin',
            },
          );
          return;
        }
        
        // Extract the original error from wrapped exceptions
        String errorToProcess = error.toString();
        if (error.toString().contains('AuthRetryableFetchException') || 
            error.toString().contains('SocketFailed') ||
            error.toString().contains('host lookup')) {
          errorToProcess = 'SocketFailed host lookup';
        }
        
        String friendlyMessage = OfflineHandler.getAuthErrorMessage(errorToProcess);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    friendlyMessage,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ),
              ],
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleOTPLogin() async {
    if (_validateEmail(_emailController.text) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a valid email address',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.instance.signInWithOTP(
        email: _emailController.text.trim(),
      );

      if (mounted) {
        // Success - trigger haptic feedback
        HapticFeedback.lightImpact();

        // Navigate to OTP verification screen
        Navigator.pushNamed(
          context,
          '/otp-verification',
          arguments: {
            'email': _emailController.text.trim(),
            'type': 'signin',
          },
        );
      }
    } catch (error) {
      if (mounted) {
        // Extract the original error from wrapped exceptions for OTP login
        String errorToProcess = error.toString();
        if (error.toString().contains('AuthRetryableFetchException') || 
            error.toString().contains('SocketFailed') ||
            error.toString().contains('host lookup')) {
          errorToProcess = 'SocketFailed host lookup';
        }
        
        String friendlyMessage = OfflineHandler.getAuthErrorMessage(errorToProcess);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    friendlyMessage,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ),
              ],
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Future<void> _handleSocialLogin(String provider) async {
  //   HapticFeedback.selectionClick();

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         '$provider login will be implemented with SDK integration',
  //         style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
  //           color: Colors.white,
  //         ),
  //       ),
  //       backgroundColor: AppTheme.lightTheme.colorScheme.primary,
  //       behavior: SnackBarBehavior.floating,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //     ),
  //   );
  // }

  void _handleForgotPassword() {
    HapticFeedback.selectionClick();

    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter your email address first',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    // Navigate to password reset screen to send OTP first
    Navigator.pushNamed(context, '/password-reset');
  }

  void _navigateToSignUp() {
    HapticFeedback.selectionClick();
    Navigator.pushNamed(context, '/signup-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  SizedBox(height: 4.h),

                  // App Title Section
                  Text(
                    'Connect, Share, Discover',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  SizedBox(height: 6.h),

                  // Login Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email Field
                        CustomTextField(
                          label: 'Email',
                          hint: 'Enter your email',
                          iconName: 'email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),

                        SizedBox(height: 3.h),

                        // Password Field
                        CustomTextField(
                          label: 'Password',
                          hint: 'Enter your password',
                          iconName: 'lock',
                          controller: _passwordController,
                          isPassword: true,
                          showVisibilityToggle: true,
                          validator: _validatePassword,
                        ),

                        SizedBox(height: 2.h),

                        // Remember Me & Forgot Password Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 5.w,
                                  height: 5.w,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                                    activeColor:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Remember me',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: _handleForgotPassword,
                              child: Text(
                                'Forgot Password?',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 4.h),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 6.h,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppTheme.lightTheme.colorScheme.primary,
                              foregroundColor:
                                  AppTheme.lightTheme.colorScheme.onPrimary,
                              elevation: 2,
                              shadowColor: AppTheme
                                  .lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 5.w,
                                    height: 5.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme
                                            .lightTheme.colorScheme.onPrimary,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Login',
                                    style: AppTheme
                                        .lightTheme.textTheme.labelLarge
                                        ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: 2.h),

                        // Login with OTP Button
                        SizedBox(
                          width: double.infinity,
                          height: 6.h,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _handleOTPLogin,
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  AppTheme.lightTheme.colorScheme.primary,
                              side: BorderSide(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Login with OTP',
                              style: AppTheme.lightTheme.textTheme.labelLarge
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // SizedBox(height: 4.h),

                  // Divider - Commented out since social login is disabled
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: Divider(
                  //         color: AppTheme.lightTheme.colorScheme.outline
                  //             .withValues(alpha: 0.3),
                  //         thickness: 1,
                  //       ),
                  //     ),
                  //     Padding(
                  //       padding: EdgeInsets.symmetric(horizontal: 4.w),
                  //       child: Text(
                  //         'Or continue with',
                  //         style:
                  //             AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  //           color: AppTheme.lightTheme.colorScheme.onSurface
                  //               .withValues(alpha: 0.6),
                  //         ),
                  //       ),
                  //     ),
                  //     Expanded(
                  //       child: Divider(
                  //         color: AppTheme.lightTheme.colorScheme.outline
                  //             .withValues(alpha: 0.3),
                  //         thickness: 1,
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  // SizedBox(height: 3.h),

                  // Social Login Buttons - Commented out for future use
                  // SocialLoginButton(
                  //   iconName: 'g_translate',
                  //   label: 'Continue with Google',
                  //   backgroundColor: Colors.white,
                  //   textColor: AppTheme.lightTheme.colorScheme.onSurface,
                  //   onPressed: () => _handleSocialLogin('Google'),
                  // ),

                  // SocialLoginButton(
                  //   iconName: 'apple',
                  //   label: 'Continue with Apple',
                  //   backgroundColor: Colors.black,
                  //   textColor: Colors.white,
                  //   onPressed: () => _handleSocialLogin('Apple'),
                  // ),

                  // SocialLoginButton(
                  //   iconName: 'facebook',
                  //   label: 'Continue with Facebook',
                  //   backgroundColor: const Color(0xFF1877F2),
                  //   textColor: Colors.white,
                  //   onPressed: () => _handleSocialLogin('Facebook'),
                  // ),

                  const Spacer(),

                  // Sign Up Link
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'New user? ',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                        TextButton(
                          onPressed: _navigateToSignUp,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Sign Up',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
