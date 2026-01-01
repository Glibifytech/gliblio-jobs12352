import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../utils/error_checker.dart';
import '../../utils/offline_handling.dart';
import '../../widgets/username_validator_widget.dart';
import '../login_screen/widgets/custom_text_field.dart';
// import '../login_screen/widgets/social_login_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onUsernameValidationChanged(bool isValid, String? errorMessage) {
    // Username validation handled by the widget itself
    // This callback can be used for additional logic if needed
  }

  Future<void> _handleSignUp() async {
    // Pre-validate everything
    final validationResult = await ErrorChecker.validateSignupData(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      fullName: _fullNameController.text.trim(),
    );

    // Check for validation errors
    if (!validationResult.isValid) {
      _showErrorMessage(validationResult.firstError);
      return;
    }

    if (!_acceptedTerms) {
      _showErrorMessage('Please accept the Terms and Conditions to continue');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService.instance.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        username: _usernameController.text.trim(),
      );

      if (mounted) {
        if (response.user != null) {
          // Success - trigger haptic feedback
          HapticFeedback.lightImpact();

          _showSuccessMessage('Account created successfully! Please check your email for verification.');

          // Navigate to OTP verification screen after a brief delay
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
          Navigator.pushNamed(
            context,
            '/otp-verification',
            arguments: {
              'email': _emailController.text.trim(),
              'type': 'signup',
            },
          );
            }
          });
        } else {
          throw Exception('Signup failed - no user returned');
        }
      }
    } catch (error) {
      if (mounted) {
        // Use OfflineHandler first for network errors, fallback to ErrorChecker
        String friendlyMessage = OfflineHandler.getAuthErrorMessage(error);
        if (friendlyMessage == 'Something went wrong. Please try again later.') {
          friendlyMessage = ErrorChecker.getErrorMessage(error);
        }
        _showErrorMessage(friendlyMessage);
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
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
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleOTPSignUp() async {
    if (_validateEmail(_emailController.text) != null) {
      _showErrorMessage('Please enter a valid email address');
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
        HapticFeedback.lightImpact();
        _showSuccessMessage('OTP sent to your email! Please check your inbox.');

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushNamed(
              context,
              '/otp-verification',
              arguments: {
                'email': _emailController.text.trim(),
                'type': 'signup',
              },
            );
          }
        });
      }
    } catch (error) {
      if (mounted) {
        String friendlyMessage = OfflineHandler.getAuthErrorMessage(error);
        _showErrorMessage(friendlyMessage);
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
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

  void _showLegalOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 10.w,
                height: 1.h,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 2.h),
              
              Text(
                'Legal Documents',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              
              // Terms and Conditions
              ListTile(
                leading: Icon(
                  Icons.description_outlined,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                title: const Text(
                  'Terms and Conditions',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(
                  Icons.open_in_new,
                  color: Colors.grey[400],
                ),
                onTap: () {
                  Navigator.pop(context);
                  _launchUrl('https://youthful-truffle-5c7.notion.site/Gliblio-2ad8dac6fc588013bdbee0cb07efeb60?source=copy_link');
                },
              ),
              
              // Privacy Policy
              ListTile(
                leading: Icon(
                  Icons.privacy_tip_outlined,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                title: const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(
                  Icons.open_in_new,
                  color: Colors.grey[400],
                ),
                onTap: () {
                  Navigator.pop(context);
                  _launchUrl('https://youthful-truffle-5c7.notion.site/2698dac6fc58803a8042f62628105fd5?source=copy_link');
                },
              ),
              
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (mounted) {
        _showErrorMessage('Could not open the link');
      }
    }
  }

  // Future<void> _handleSocialSignup(OAuthProvider provider) async {
  //   HapticFeedback.selectionClick();

  //   try {
  //     await AuthService.instance.signInWithOAuth(provider);
  //   } catch (error) {
  //     if (mounted) {
  //       // Use OfflineHandler for network and auth errors
  //       String friendlyMessage = OfflineHandler.getAuthErrorMessage(error);
  //       _showErrorMessage(friendlyMessage);
  //     }
  //   }
  // }

  void _navigateToLogin() {
    HapticFeedback.selectionClick();
    Navigator.pushReplacementNamed(context, '/login-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            children: [
              SizedBox(height: 3.h),

              // App Title Section
              Text(
                'Connect, Share, Discover',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w400,
                ),
              ),

              SizedBox(height: 4.h),

              // Signup Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name Field
                    CustomTextField(
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      iconName: 'person',
                      controller: _fullNameController,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Full name is required';
                        }
                        if (value.length < 2) {
                          return 'Full name must be at least 2 characters';
                        }
                        if (value.length > 50) {
                          return 'Full name must be less than 50 characters';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 3.h),

                    // Username Field with Real-time Validation
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Username',
                          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        UsernameValidatorWidget(
                      controller: _usernameController,
                          hintText: 'Choose a unique username',
                          onValidationChanged: _onUsernameValidationChanged,
                          enabled: !_isLoading,
                        ),
                      ],
                    ),

                    SizedBox(height: 3.h),

                    // Email Field
                    CustomTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      iconName: 'email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => ErrorChecker.validateEmail(value ?? ''),
                    ),

                    SizedBox(height: 3.h),

                    // Password Field
                    CustomTextField(
                      label: 'Password',
                      hint: 'Create a strong password',
                      iconName: 'lock',
                      controller: _passwordController,
                      isPassword: true,
                      showVisibilityToggle: true,
                      validator: (value) => ErrorChecker.validatePassword(value ?? ''),
                    ),

                    SizedBox(height: 3.h),

                    // Confirm Password Field
                    CustomTextField(
                      label: 'Confirm Password',
                      hint: 'Confirm your password',
                      iconName: 'lock_outline',
                      controller: _confirmPasswordController,
                      isPassword: true,
                      showVisibilityToggle: true,
                      validator: (value) => ErrorChecker.validatePasswordConfirmation(
                        _passwordController.text,
                        value ?? '',
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Terms and Conditions Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 5.w,
                          height: 5.w,
                          child: Checkbox(
                            value: _acceptedTerms,
                            onChanged: (value) {
                              setState(() {
                                _acceptedTerms = value ?? false;
                              });
                            },
                            activeColor:
                                AppTheme.lightTheme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showLegalOptions(context),
                            child: Text.rich(
                              TextSpan(
                                text: 'I agree to the ',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme.lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Terms and Conditions',
                                    style: TextStyle(
                                      color:
                                          AppTheme.lightTheme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color:
                                          AppTheme.lightTheme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 4.h),

                    // Signup Button
                    SizedBox(
                      width: double.infinity,
                      height: 6.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppTheme.lightTheme.colorScheme.primary,
                          foregroundColor:
                              AppTheme.lightTheme.colorScheme.onPrimary,
                          elevation: 2,
                          shadowColor: AppTheme.lightTheme.colorScheme.primary
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
                                    AppTheme.lightTheme.colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : Text(
                                'Sign Up',
                                style: AppTheme.lightTheme.textTheme.labelLarge
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Sign up with OTP Button
                    SizedBox(
                      width: double.infinity,
                      height: 6.h,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _handleOTPSignUp,
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
                          'Sign up with OTP',
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

              // Divider - Commented out since social signup is disabled
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
              //         'Or sign up with',
              //         style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
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

              // Social Signup Buttons - Commented out for future use
              // SocialLoginButton(
              //   iconName: 'g_translate',
              //   label: 'Sign up with Google',
              //   backgroundColor: Colors.white,
              //   textColor: AppTheme.lightTheme.colorScheme.onSurface,
              //   onPressed: () => _handleSocialSignup(OAuthProvider.google),
              // ),

              // SocialLoginButton(
              //   iconName: 'apple',
              //   label: 'Sign up with Apple',
              //   backgroundColor: Colors.black,
              //   textColor: Colors.white,
              //   onPressed: () => _handleSocialSignup(OAuthProvider.apple),
              // ),

              // SocialLoginButton(
              //   iconName: 'facebook',
              //   label: 'Sign up with Facebook',
              //   backgroundColor: const Color(0xFF1877F2),
              //   textColor: Colors.white,
              //   onPressed: () => _handleSocialSignup(OAuthProvider.facebook),
              // ),

              SizedBox(height: 4.h),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                  TextButton(
                    onPressed: _navigateToLogin,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Sign In',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}
