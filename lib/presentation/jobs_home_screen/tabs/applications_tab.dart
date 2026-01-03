import 'package:flutter/material.dart';
import '../widgets/application_card_widget.dart';
import '../../../widgets/custom_loading.dart';

class ApplicationsTab extends StatefulWidget {
  const ApplicationsTab({super.key});

  @override
  State<ApplicationsTab> createState() => _ApplicationsTabState();
}

class _ApplicationsTabState extends State<ApplicationsTab> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading
    Future.delayed(Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  // Mock data - applications received for my job postings
  final List<Map<String, dynamic>> _mockApplications = [
    {
      'id': '1',
      'applicantName': 'John Smith',
      'applicantAvatar': 'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=800&h=600&fit=crop&q=80',
      'jobTitle': 'DevOps Engineer',
      'appliedDate': '2d ago',
      'status': 'pending', // pending, reviewed, accepted, rejected
      'email': 'john.smith@email.com',
      'phone': '+1 (555) 123-4567',
      'coverLetter': 'I am writing to express my strong interest in the DevOps Engineer position. With 5+ years of experience in cloud infrastructure and automation, I believe I would be a great fit for your team. My expertise includes AWS, Docker, Kubernetes, and CI/CD pipeline implementation.',
      'skills': ['AWS', 'Docker', 'Kubernetes', 'Python', 'CI/CD'],
      'resumeUrl': 'https://example.com/resume.pdf',
    },
    {
      'id': '2',
      'applicantName': 'Sarah Johnson',
      'applicantAvatar': 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=1200',
      'jobTitle': 'Senior Flutter Developer',
      'appliedDate': '1w ago',
      'status': 'reviewed',
      'email': 'sarah.j@email.com',
      'phone': '+1 (555) 987-6543',
      'coverLetter': 'I have been working with Flutter for 3+ years and have built multiple production apps. I am passionate about creating beautiful, performant mobile applications and would love to join your innovative team.',
      'skills': ['Flutter', 'Dart', 'Firebase', 'REST APIs', 'State Management'],
      'resumeUrl': 'https://example.com/resume.pdf',
    },
    {
      'id': '3',
      'applicantName': 'Michael Chen',
      'applicantAvatar': 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=1200',
      'jobTitle': 'DevOps Engineer',
      'appliedDate': '3d ago',
      'status': 'pending',
      'email': 'michael.chen@email.com',
      'phone': '+1 (555) 456-7890',
      'coverLetter': 'With extensive experience in DevOps practices and cloud infrastructure, I am excited about the opportunity to contribute to your team. I have successfully implemented automated deployment pipelines and managed large-scale cloud infrastructure.',
      'skills': ['Azure', 'Jenkins', 'Terraform', 'Docker', 'Monitoring'],
      'resumeUrl': 'https://example.com/resume.pdf',
    },
  ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: Center(child: CustomLoading()),
      );
    }

    if (_mockApplications.isEmpty) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 80, color: Colors.black26),
              SizedBox(height: 24),
              Text(
                'No Applications Yet',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Applications for your job posts will appear here',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header with count
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Applications',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_mockApplications.length}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Applications list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _mockApplications.length,
              itemBuilder: (context, index) {
                final application = _mockApplications[index];
                return ApplicationCardWidget(
                  application: application,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/application-details',
                      arguments: application,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
