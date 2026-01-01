import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_export.dart';
import 'widgets/custom_error_widget.dart';
import './services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  Map<String, dynamic> env = {};
  try {
    final envString = await rootBundle.loadString('env.json');
    env = json.decode(envString);
  } catch (e) {
    // Silent fail
  }

  // 🔐 1. Supabase — MUST be before runApp for routing
  try {
    await SupabaseService.initialize(
      supabaseUrl: env['supabaseUrl'] ?? '',
      supabaseAnonKey: env['supabaseAnonKey'] ?? '',
    );
  } catch (e) {
    // Silent fail
  }

  bool hasShownError = false;

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!hasShownError) {
      hasShownError = true;
      Future.delayed(const Duration(seconds: 1), () {
        hasShownError = false;
      });
      return CustomErrorWidget(errorDetails: details);
    }
    return const SizedBox.shrink();
  };

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 🎬 runApp IMMEDIATELY after minimal setup
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    
    // ALWAYS start processing - no matter what (like Glibify)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _processAppStart();
    });
  }

  void _processAppStart() async {
    try {
      // Check if first launch
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
      
      if (!hasSeenOnboarding) {
        // First launch - show onboarding
        _navigatorKey.currentState?.pushReplacementNamed(AppRoutes.onboarding);
        return;
      }
      
      // FORCE a minimum delay to ensure everything is ready
      await Future.delayed(Duration(milliseconds: 100));
      
      // Wait for auth to be ready
      await _waitForAuth();
      
      // FORCE another delay
      await Future.delayed(Duration(milliseconds: 50));
      
      final isLoggedIn = SupabaseService.instance.client.auth.currentSession != null;
      
      // Navigate
      final route = isLoggedIn ? AppRoutes.home : AppRoutes.login;
      _navigatorKey.currentState?.pushReplacementNamed(route);
    } catch (e) {
      // Fallback to normal launch
      final isLoggedIn = SupabaseService.instance.client.auth.currentSession != null;
      final route = isLoggedIn ? AppRoutes.home : AppRoutes.login;
      _navigatorKey.currentState?.pushReplacementNamed(route);
    }
  }
  
  Future<void> _waitForAuth() async {
    while (true) {
      try {
        SupabaseService.instance.client.auth.currentSession;
        break;
      } catch (e) {
        await Future.delayed(Duration(milliseconds: 50));
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          title: 'Gliblio Jobs',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          builder: (context, child) {
            SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
              statusBarColor: Colors.white,
              statusBarIconBrightness: Brightness.dark,
              systemNavigationBarColor: Colors.white,
              systemNavigationBarIconBrightness: Brightness.dark,
            ));
            
            return child!;
          },
          debugShowCheckedModeBanner: false,
          routes: AppRoutes.routes,
          onGenerateRoute: AppRoutes.generateRoute,
          initialRoute: AppRoutes.initial,
        );
      },
    );
  }

  Future<void> _initializeDeferredServices() async {
    // Services removed for MVP
  }
}