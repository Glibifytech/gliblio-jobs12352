import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/auth_service.dart';
import '../../utils/offline_handling.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _confirmationController = TextEditingController();
  bool _isDeleting = false;
  final String _requiredText = 'delete my account';
  Map<String, dynamic>? _env;

  @override
  void initState() {
    super.initState();
    _loadEnv();
  }

  Future<void> _loadEnv() async {
    try {
      final envString = await rootBundle.loadString('env.json');
      _env = json.decode(envString);
    } catch (e) {
      _env = {};
    }
  }

  Future<void> _deleteAccount() async {
    if (_confirmationController.text != _requiredText) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please type the confirmation text exactly as shown'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Show dialog to choose between immediate and soft deletion
    final deletionType = await _showDeletionTypeDialog();
    if (deletionType == null) return; // User cancelled

    final user = AuthService.instance.currentUser;
    final session = AuthService.instance.currentSession;
    
    if (user == null || session == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not logged in'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      final userId = user.id;

      // Step 1: Call the appropriate Edge Function based on user choice
      String functionUrl;
      
      if (deletionType == 'immediate') {
        functionUrl = _env?['immediatelyDeleteUrl'] ?? '';
      } else {
        functionUrl = _env?['edgeFunctionUrl'] ?? '';
      }
      
      final url = Uri.parse(functionUrl);
      final headers = <String, String>{
        'Authorization': 'Bearer ${session.accessToken}',
        'apikey': _env?['supabaseAnonKey'] ?? '',
        'Content-Type': 'application/json',
      };
      
      final body = jsonEncode({
        'userId': userId,
      });
      
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete account');
      }

      // Small delay to ensure deletion is processed
      await Future.delayed(const Duration(seconds: 1));

      // Step 2: Sign out the user
      await AuthService.instance.signOut();

      if (mounted) {
        String successMessage;
        if (deletionType == 'immediate') {
          successMessage = 'Account and all data deleted permanently';
        } else {
          successMessage = 'Account marked for deletion successfully';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to login screen
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/login-screen', 
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        final sanitizedError = OfflineHandler.getAuthErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(sanitizedError),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<String?> _showDeletionTypeDialog() async {
    return await showDialog<String?> (
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account Type'),
          content: const Text('Choose how you want to delete your account:\n\nImmediate: Delete all data permanently now\n\nSoft Delete: Mark for deletion with 48-hour grace period'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'soft'),
              child: const Text('Soft Delete'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'immediate'),
              child: const Text('Immediate'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Delete Account',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Permanently Delete Account',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'This action cannot be undone. This will permanently delete your account and remove all your data from our servers.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 3.h),
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.error,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: colorScheme.onErrorContainer,
                          size: 24,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Warning',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      '• Your account will be marked for deletion\n'
                      '• You will be logged out of all devices\n'
                      '• Your data will be permanently deleted after 48 hours\n'
                      '• You can restore your account within this period\n'
                      '• This action cannot be reversed after the grace period',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'To confirm, please type "$_requiredText" in the box below:',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 1.h),
              TextField(
                controller: _confirmationController,
                decoration: InputDecoration(
                  hintText: _requiredText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isDeleting ? null : _deleteAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isDeleting
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onError,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            const Text('Deleting Account...'),
                          ],
                        )
                      : const Text(
                          'Delete Account Permanently',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}