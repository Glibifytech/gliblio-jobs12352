import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../services/user_service.dart';
import '../../core/app_export.dart';
import '../../core/caching/user_profile_cache.dart';
import './tabs/home_tab.dart';
import './tabs/post_jobs_tab.dart';
import './tabs/applications_tab.dart';
import './tabs/saved_tab.dart';
import './tabs/alert_tab.dart';

class JobsHomeScreen extends StatefulWidget {
  const JobsHomeScreen({super.key});

  @override
  State<JobsHomeScreen> createState() => _JobsHomeScreenState();
}

class _JobsHomeScreenState extends State<JobsHomeScreen> {
  int _selectedIndex = 0;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      // Check cache first
      final cachedProfile = UserProfileCache().profile;
      if (cachedProfile != null) {
        if (mounted) {
          setState(() {
            _avatarUrl = cachedProfile['avatar_url'];
          });
        }
        return;
      }

      // Fetch from API if not cached
      final profile = await UserService.instance.getCurrentUserProfile();
      if (mounted && profile != null) {
        // Cache the profile
        UserProfileCache().setProfile(profile);
        setState(() {
          _avatarUrl = profile['avatar_url'];
        });
      }
    } catch (e) {
      // Silent fail
    }
  }

  final List<Widget> _screens = [
    HomeTab(),
    PostJobsTab(),
    ApplicationsTab(),
    SavedTab(),
    AlertTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                  ? NetworkImage(_avatarUrl!)
                  : null,
              child: _avatarUrl == null || _avatarUrl!.isEmpty
                  ? Icon(Icons.person, color: Colors.grey[400])
                  : null,
            ),
          ),
        ),
        title: Text(
          'Gliblio Jobs',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: SafeArea(
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home, 'Home'),
                _buildNavItem(1, Icons.add_circle_outline, 'Post Jobs'),
                _buildNavItem(2, Icons.work_outline, 'Apply'),
                _buildNavItem(3, Icons.bookmark_border, 'Saved'),
                _buildNavItem(4, Icons.notifications_outlined, 'Alert'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.grey[400],
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.grey[400],
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
