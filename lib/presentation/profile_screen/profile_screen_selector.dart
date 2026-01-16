import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/supabase_service.dart';
import './profile_screen.dart';
import './guest_profile_screen.dart';
import '../../services/guest_user_manager.dart';

class ProfileScreenSelector extends StatefulWidget {
  const ProfileScreenSelector({super.key});

  @override
  State<ProfileScreenSelector> createState() => _ProfileScreenSelectorState();
}

class _ProfileScreenSelectorState extends State<ProfileScreenSelector> {
  bool _isLoading = true;
  bool _isGuestUser = false;

  @override
  void initState() {
    super.initState();
    _checkUserType();
  }

  Future<void> _checkUserType() async {
    // Check if user is authenticated
    final isLoggedIn = SupabaseService.instance.client.auth.currentSession != null;
    
    // Check if user is a guest
    final isGuest = await GuestUserManager.instance.isGuestUser();
    
    setState(() {
      _isGuestUser = !isLoggedIn && isGuest;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Colors.black),
        ),
      );
    }

    // Show appropriate profile screen based on user type
    if (_isGuestUser) {
      return const GuestProfileScreen();
    } else {
      return const ProfileScreen();
    }
  }
}