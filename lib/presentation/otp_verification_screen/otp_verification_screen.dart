import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../password_reset/new_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String? email;
  final bool isPasswordReset;
  
  const OtpVerificationScreen({
    super.key,
    this.email,
    this.isPasswordReset = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResendLoading = false;
  int _resendCountdown = 0;
  Timer? _countdownTimer;

  String? _email;
  String? _phone;
  String _type = 'signup'; // 'signup', 'signin', 'recovery'

  @override
  void initState() {
    super.initState();
    if (widget.email != null) {
      _email = widget.email;
      _type = widget.isPasswordReset ? 'recovery' : 'signup';
    }
    
    // For password reset, OTP was already sent, so start countdown immediately
    // For other flows, also start countdown as OTP should have been sent
    _startResendCountdown();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get arguments from route
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _email = args['email'] as String?;
      _phone = args['phone'] as String?;
      _type = args['type'] as String? ?? 'signup';
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() {
      _resendCountdown = 60; // 60 seconds countdown
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _resendCountdown--;
      });

      if (_resendCountdown <= 0) {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter the complete 6-digit code',
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
      // For email OTP verification, use OtpType.email
      final response = await AuthService.instance.verifyOTP(
        token: _otpController.text,
        type: OtpType.email,
        email: _email,
        phone: _phone,
      );

      if (mounted) {
        if (response.user != null) {
          // Success - trigger haptic feedback
          HapticFeedback.lightImpact();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _type == 'signup'
                    ? 'Account verified successfully!'
                    : 'Login successful!',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );

          // Navigate based on flow type
          // OTP Verification
          
          if (widget.isPasswordReset) {
            // For password reset, go to new password screen
            if (_email != null) {
              // Navigating to NewPasswordScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => NewPasswordScreen(email: _email!),
                ),
              );
            } else {
              // Error: Email is null for password reset
              throw Exception('Email is required for password reset');
            }
          } else {
            // For normal signup/signin, go to home screen
            // Navigating to home screen
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home-screen',
              (route) => false,
            );
          }
        } else {
          throw Exception('Verification failed - no user returned');
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Verification failed: ${error.toString().replaceAll('Exception: ', '')}',
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
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOTP() async {
    if (_resendCountdown > 0 || _isResendLoading) return;

    setState(() {
      _isResendLoading = true;
    });

    try {
      // Resend OTP based on the flow type
      if (_type == 'recovery' || widget.isPasswordReset) {
        // For password reset, use resetPassword
        if (_email != null) {
          await AuthService.instance.resetPassword(email: _email!);
        } else {
          throw Exception('No email provided for password reset');
        }
      } else {
        // For signup/signin, use signInWithOTP
        if (_email != null) {
          await AuthService.instance.signInWithOTP(email: _email);
        } else if (_phone != null) {
          await AuthService.instance.signInWithOTP(phone: _phone);
        } else {
          throw Exception('No email or phone provided');
        }
      }

      if (mounted) {
        // Success - trigger haptic feedback
        HapticFeedback.lightImpact();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Verification code sent successfully!',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        // Start countdown again
        _startResendCountdown();

        // Clear current OTP input
        _otpController.clear();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to resend code: ${error.toString().replaceAll('Exception: ', '')}',
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
      }
    }

    if (mounted) {
      setState(() {
        _isResendLoading = false;
      });
    }
  }

  String get _contactType {
    if (_email != null) {
      return 'email';
    } else if (_phone != null) {
      return 'phone';
    }
    return 'contact';
  }

  String get _screenDescription {
    switch (_type) {
      case 'signup':
        return 'We have sent a verification code to your $_contactType. Please enter it below to complete your account setup.';
      case 'signin':
        return 'We have sent a verification code to your $_contactType. Please enter it below to sign in.';
      case 'recovery':
        return 'We have sent a password reset code to your $_contactType. Please enter it below to reset your password.';
      default:
        return 'Enter the verification code sent to your $_contactType.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            children: [
              SizedBox(height: 15.h),
              
              // Title
              Text(
                'Enter OTP',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              
              SizedBox(height: 2.h),
              
              // Subtitle
              Text(
                _screenDescription,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 6.h),
              
              // OTP Input Field - Simple single field
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    hintText: 'OTP',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 3.h,
                    ),
                    counterText: '',
                  ),
                  onChanged: (value) {
                    if (value.length == 6) {
                      _verifyOTP();
                    }
                  },
                ),
              ),
              
              SizedBox(height: 4.h),
              
              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Verify OTP',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              SizedBox(height: 3.h),
              
              // Resend OTP
              if (_resendCountdown > 0)
                Text(
                  'Resend OTP in ${_resendCountdown}s',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                )
              else
                TextButton(
                  onPressed: _isResendLoading ? null : _resendOTP,
                  child: _isResendLoading
                      ? SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        )
                      : Text(
                          'Resend OTP',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
