import 'package:flutter/material.dart';
import '../widgets/job_card_widget.dart';
import '../../../widgets/custom_loading.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
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
  // Mock data
  final List<Map<String, dynamic>> _mockJobs = [
    {
      'title': 'DevOps Engineer',
      'company': 'CloudTech Systems',
      'location': 'Seattle, WA',
      'jobType': 'Full-time',
      'workMode': 'Remote',
      'salaryRange': '\$140,000 - \$180,000',
      'description': 'Join our infrastructure team as a DevOps Engineer to help build and maintain our cloud infrastructure...',
      'skills': ['AWS/Azure experience', 'Docker/Kubernetes', 'CI/CD pipelines', 'Python'],
      'postedTime': '4d ago',
      'isFeatured': true,
      'externalLink': 'https://careers.cloudtech.com/apply',
      'posterId': 'user123',
      'posterName': 'John Anderson',
      'posterUsername': '@johnanderson',
      'posterAvatar': 'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=800&h=600&fit=crop&q=80',
      'posterBio': 'Tech recruiter at CloudTech Systems. Helping talented engineers find their dream roles.',
      'posterSkills': ['Recruitment', 'Tech Hiring', 'Networking'],
    },
    {
      'title': 'Senior Flutter Developer',
      'company': 'Tech Innovations Inc',
      'location': 'San Francisco, CA',
      'jobType': 'Full-time',
      'workMode': 'Hybrid',
      'salaryRange': '\$120,000 - \$150,000',
      'description': 'We are looking for an experienced Flutter developer to join our mobile team and build cutting-edge apps...',
      'skills': ['Flutter', 'Dart', 'Firebase', 'REST APIs'],
      'postedTime': '1w ago',
      'isFeatured': false,
      'externalLink': '',
      'posterId': 'user456',
      'posterName': 'Sarah Chen',
      'posterUsername': '@sarahchen',
      'posterAvatar': 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=1200',
      'posterBio': 'Engineering Manager at Tech Innovations. Building the future of mobile apps.',
      'posterSkills': ['Flutter', 'Team Leadership', 'Mobile Development'],
    },
    {
      'title': 'UI/UX Designer',
      'company': 'Design Hub',
      'location': 'New York, NY',
      'jobType': 'Contract',
      'workMode': 'Remote',
      'salaryRange': '\$80,000 - \$100,000',
      'description': 'Creative UI/UX designer needed to work on multiple projects for various clients...',
      'skills': ['Figma', 'Adobe XD', 'Prototyping', 'User Research'],
      'postedTime': '2d ago',
      'isFeatured': false,
      'externalLink': 'https://designhub.com/careers/apply',
      'posterId': 'user789',
      'posterName': 'Michael Roberts',
      'posterUsername': '@michaelr',
      'posterAvatar': 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=1200',
      'posterBio': 'Creative Director at Design Hub. Passionate about great user experiences.',
      'posterSkills': ['UI/UX Design', 'Product Design', 'Design Systems'],
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

    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _mockJobs.length,
        itemBuilder: (context, index) {
          final job = _mockJobs[index];
          return JobCardWidget(
            title: job['title'],
            company: job['company'],
            location: job['location'],
            jobType: job['jobType'],
            workMode: job['workMode'],
            salaryRange: job['salaryRange'],
            description: job['description'],
            skills: List<String>.from(job['skills']),
            postedTime: job['postedTime'],
            isFeatured: job['isFeatured'],
            onViewDetails: () {
              Navigator.pushNamed(
                context,
                '/job-details',
                arguments: job,
              );
            },
            onApply: () {
              Navigator.pushNamed(
                context,
                '/apply-job',
                arguments: job,
              );
            },
            onSave: () {
              // TODO: Save job
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Saved ${job['title']}')),
              );
            },
          );
        },
      ),
    );
  }
}
