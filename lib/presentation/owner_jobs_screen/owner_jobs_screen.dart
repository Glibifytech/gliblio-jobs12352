import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../repositories/jobs_repository.dart';
import '../owner_job_details_screen/owner_job_details_screen.dart';

class OwnerJobsScreen extends StatefulWidget {
  const OwnerJobsScreen({super.key});

  @override
  State<OwnerJobsScreen> createState() => _OwnerJobsScreenState();
}

class _OwnerJobsScreenState extends State<OwnerJobsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _jobs = [];
  final JobsRepository _jobsRepository = JobsRepository();

  @override
  void initState() {
    super.initState();
    _loadOwnerJobs();
  }

  Future<void> _loadOwnerJobs() async {
    try {
      final user = SupabaseService.instance.client.auth.currentUser;
      final userId = user?.id;
      
      if (userId != null) {
        final jobs = await _jobsRepository.getJobsByPosterId(userId);
        setState(() {
          _jobs = jobs;
          _isLoading = false;
        });
      } else {
        setState(() {
          _jobs = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _jobs = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: Center(child: CircularProgressIndicator()),
      );
    }

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
          'My Posted Jobs',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      body: _jobs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_outline, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No jobs posted yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'When you post jobs, they will appear here',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : Container(
              color: Colors.white,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _jobs.length,
                itemBuilder: (context, index) {
                  final job = _jobs[index];
                  return _buildJobCard(job);
                },
              ),
            ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    final skills = List<String>.from(job['requirements'] ?? []);
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OwnerJobDetailsScreen(job: job),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job['title'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          job['company_name'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    job['location'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: skills.take(3).map((skill) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (skills.length > 3) ...[
                SizedBox(height: 4),
                Text(
                  '+${skills.length - 3} more',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job['job_type']?.toString().toUpperCase().replaceAll('-', ' ') ?? 'N/A',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          job['salary_range_min'] != null && job['salary_range_max'] != null
                              ? '₦${job['salary_range_min'].toStringAsFixed(0).replaceAllMapped(RegExp(r'(\\d)(?=(\\d{3})+(?!\\d))'), (Match m) => '\${m[1]},')} - ₦${job['salary_range_max'].toStringAsFixed(0).replaceAllMapped(RegExp(r'(\\d)(?=(\\d{3})+(?!\\d))'), (Match m) => '\${m[1]},')}'
                              : 'Salary not specified',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}