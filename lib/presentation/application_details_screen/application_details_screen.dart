import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicationDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> application;

  const ApplicationDetailsScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final skills = List<dynamic>.from(application['skills']);
    final status = application['status'] as String;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Application Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Applicant header
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      application['applicantAvatar'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.person, size: 50, color: Colors.grey[400]),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    application['applicantName'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Applied for ${application['jobTitle']}',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    application['appliedDate'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, thickness: 1),

            // Contact information
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Contact Information'),
                  SizedBox(height: 12),
                  _buildContactItem(
                    Icons.email,
                    'Email',
                    application['email'],
                    () => _launchEmail(application['email']),
                  ),
                  SizedBox(height: 8),
                  _buildContactItem(
                    Icons.phone,
                    'Phone',
                    application['phone'],
                    () => _launchPhone(application['phone']),
                  ),
                ],
              ),
            ),

            Divider(height: 1, thickness: 1),

            // Cover letter
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Cover Letter'),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(
                      application['coverLetter'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, thickness: 1),

            // Skills
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Skills'),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: skills.map((skill) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          skill,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            Divider(height: 1, thickness: 1),

            // Resume
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Resume'),
                  SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Resume download coming soon')),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${application['applicantName']}_Resume.pdf',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(Icons.download, color: Colors.blue, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: status == 'pending'
          ? Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _handleReject(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Reject',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleAccept(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: Text(
                          'Accept',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }

  Widget _buildContactItem(
      IconData icon, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new, color: Colors.blue, size: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri.parse('mailto:$email');
    if (!await launchUrl(uri)) {
      // Handle error
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');
    if (!await launchUrl(uri)) {
      // Handle error
    }
  }

  void _handleAccept(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Accept Application'),
          ],
        ),
        content: Text(
          'Are you sure you want to accept ${application['applicantName']}\'s application? They will be notified via email.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              // TODO: Update application status in database
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to applications list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Application accepted!')),
              );
            },
            child: Text('Accept', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _handleReject(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.cancel, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Reject Application'),
          ],
        ),
        content: Text(
          'Are you sure you want to reject ${application['applicantName']}\'s application?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              // TODO: Update application status in database
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to applications list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Application rejected')),
              );
            },
            child: Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
