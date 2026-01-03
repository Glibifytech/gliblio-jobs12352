import 'package:flutter/material.dart';
import '../widgets/job_card_widget.dart';
import '../../../widgets/custom_loading.dart';

class SavedTab extends StatefulWidget {
  const SavedTab({super.key});

  @override
  State<SavedTab> createState() => _SavedTabState();
}

class _SavedTabState extends State<SavedTab> {
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

  // Mock saved jobs data
  final List<Map<String, dynamic>> _savedJobs = [
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
      'savedDate': '3d ago',
    },
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
      'savedDate': '1w ago',
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

    if (_savedJobs.isEmpty) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bookmark_outline, size: 80, color: Colors.black26),
              SizedBox(height: 24),
              Text(
                'No Saved Jobs',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Jobs you save will appear here',
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
                  'Saved Jobs',
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
                    '${_savedJobs.length}',
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
          // Saved jobs list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _savedJobs.length,
              itemBuilder: (context, index) {
                final job = _savedJobs[index];
                return Column(
                  children: [
                    JobCardWidget(
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
                        setState(() {
                          _savedJobs.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Removed from saved jobs')),
                        );
                      },
                    ),
                    // Saved date info
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.bookmark, size: 14, color: Colors.blue),
                          SizedBox(width: 4),
                          Text(
                            'Saved ${job['savedDate']}',
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
