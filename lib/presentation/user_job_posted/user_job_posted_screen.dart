import 'package:flutter/material.dart';
import '../jobs_home_screen/widgets/job_card_widget.dart';
import '../../widgets/custom_loading.dart';
import '../../repositories/jobs_repository.dart';
import '../../models/job_model.dart';
import '../../services/supabase_service.dart';

class UserJobPostedScreen extends StatefulWidget {
  const UserJobPostedScreen({Key? key}) : super(key: key);

  @override
  State<UserJobPostedScreen> createState() => _UserJobPostedScreenState();
}

class _UserJobPostedScreenState extends State<UserJobPostedScreen> {
  bool _isLoading = true;
  List<Job> _jobs = [];
  final JobsRepository _jobsRepository = JobsRepository();

  @override
  void initState() {
    super.initState();
    _loadPostedJobs();
  }

  Future<void> _loadPostedJobs() async {
    try {
      // Fetch jobs posted by current user from Supabase
      final user = SupabaseService.instance.client.auth.currentUser;
      if (user != null) {
        final jobsData = await _jobsRepository.getJobsPostedByUser(user.id);
        final jobs = jobsData.map((jobData) => Job.fromJson(jobData)).toList();
        
        setState(() {
          _jobs = jobs;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading posted jobs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

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
      child: _jobs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No jobs posted yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You haven\'t posted any jobs yet.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _jobs.length,
              itemBuilder: (context, index) {
                final job = _jobs[index];
                return JobCardWidget(
                  title: job.title,
                  company: job.company,
                  location: job.location,
                  jobType: job.jobType,
                  workMode: job.workMode,
                  salaryRange: job.salaryRange,
                  description: job.description,
                  skills: job.skills,
                  postedTime: job.postedTime,
                  isFeatured: job.isFeatured,
                  onViewDetails: () {
                    Navigator.pushNamed(
                      context,
                      '/job-details',
                      arguments: {
                        'title': job.title,
                        'company': job.company,
                        'location': job.location,
                        'jobType': job.jobType,
                        'workMode': job.workMode,
                        'salaryRange': job.salaryRange,
                        'description': job.description,
                        'skills': job.skills,
                        'postedTime': job.postedTime,
                        'isFeatured': job.isFeatured,
                        'externalLink': job.externalLink,
                        'posterId': job.posterId,
                        'posterName': job.posterName,
                        'posterUsername': job.posterUsername,
                        'posterAvatar': job.posterAvatar,
                        'posterBio': job.posterBio,
                        'posterSkills': job.posterSkills,
                      },
                    );
                  },
                  onApply: () {
                    // Do nothing - no apply button for user's own posted jobs
                  },
                  onSave: () {
                    // TODO: Save job
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Saved ${job.title}')),
                    );
                  },
                );
              },
            ),
    );
  }
}