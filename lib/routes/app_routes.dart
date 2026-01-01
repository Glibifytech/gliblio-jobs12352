import 'package:flutter/material.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/signup_screen/signup_screen.dart';
import '../presentation/otp_verification_screen/otp_verification_screen.dart';
import '../presentation/password_reset/password_reset.dart';
import '../presentation/onboarding_screen/onboarding_screen.dart';
import '../presentation/jobs_home_screen/jobs_home_screen.dart';
import '../presentation/job_details_screen/job_details_screen.dart';
import '../presentation/apply_job_screen/apply_job_screen.dart';
import '../presentation/post_job_screen/post_job_screen.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/application_details_screen/application_details_screen.dart';
import '../presentation/job_poster_profile_screen/job_poster_profile_screen.dart';

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: Colors.black),
      ),
    );
  }
}

class AppRoutes {
  static const String initial = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login-screen';
  static const String signup = '/signup-screen';
  static const String otpVerification = '/otp-verification';
  static const String home = '/home-screen';
  static const String passwordReset = '/password-reset';
  static const String jobDetails = '/job-details';
  static const String applyJob = '/apply-job';
  static const String postJob = '/post-job';
  static const String profile = '/profile';
  static const String applicationDetails = '/application-details';
  static const String jobPosterProfile = '/job-poster-profile';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const _SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
    otpVerification: (context) => const OtpVerificationScreen(),
    home: (context) => const JobsHomeScreen(),
    passwordReset: (context) => const PasswordResetScreen(),
    postJob: (context) => const PostJobScreen(),
    profile: (context) => const ProfileScreen(),
  };

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/post-job':
        return MaterialPageRoute(builder: (context) => const PostJobScreen());
      case '/profile':
        return MaterialPageRoute(builder: (context) => const ProfileScreen());
      case jobDetails:
        final job = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => JobDetailsScreen(job: job),
        );
      case applyJob:
        final job = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => ApplyJobScreen(job: job),
        );
      case '/application-details':
        final application = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => ApplicationDetailsScreen(application: application),
        );
      case '/job-poster-profile':
        final posterData = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => JobPosterProfileScreen(posterData: posterData),
        );
      default:
        return null;
    }
  }
}
