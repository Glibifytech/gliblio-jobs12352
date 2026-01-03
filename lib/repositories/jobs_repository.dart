import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class JobsRepository {
  final SupabaseClient _client = SupabaseService.instance.client;

  // Fetch all active job listings with poster profile
  Future<List<Map<String, dynamic>>> getJobs() async {
    try {
      // Fetch jobs with cached profile data
      final response = await _client
          .from('glibliojob_job_details')
          .select('*, glibliojob_post_job(*)')
          .eq('is_active', true)
          .order('created_at', ascending: false);


      if (response == null || (response as List).isEmpty) {
        return [];
      }

      // Map jobs to include poster_profile from cached columns
      final jobsWithProfiles = (response as List).map((job) {
        
        return <String, dynamic>{
          ...job as Map<String, dynamic>,
          'poster_profile': {
            'id': job['posted_by'],
            'username': job['poster_username'],
            'full_name': job['poster_full_name'],
            'avatar_url': job['poster_avatar_url'],
          },
        };
      }).toList();

      if (jobsWithProfiles.isNotEmpty) {
      }

      return jobsWithProfiles;
    } catch (e) {
      rethrow;
    }
  }

  // Fetch jobs by poster ID
  Future<List<Map<String, dynamic>>> getJobsByPosterId(String posterId) async {
    try {
      // Fetch jobs with cached profile data for a specific poster
      final response = await _client
          .from('glibliojob_job_details')
          .select('*, glibliojob_post_job(*)')
          .eq('posted_by', posterId)
          .order('created_at', ascending: false);

      if (response == null || (response as List).isEmpty) {
        return [];
      }

      // Map jobs to include poster_profile from cached columns
      final jobsWithProfiles = (response as List).map((job) {
        return <String, dynamic>{
          ...job as Map<String, dynamic>,
          'poster_profile': {
            'id': job['posted_by'],
            'username': job['poster_username'],
            'full_name': job['poster_full_name'],
            'avatar_url': job['poster_avatar_url'],
          },
        };
      }).toList();

      return jobsWithProfiles;
    } catch (e) {
      rethrow;
    }
  }

  // Fetch a specific job by ID with poster profile
  Future<Map<String, dynamic>?> getJobById(String jobId) async {
    try {
      // Fetch job with cached profile data
      final job = await _client
          .from('glibliojob_job_details')
          .select('*, glibliojob_post_job(*)')
          .eq('id', jobId)
          .single();


      if (job == null) {
        return null;
      }

      // Return job with poster_profile from cached columns
      final jobWithProfile = <String, dynamic>{
        ...job as Map<String, dynamic>,
        'poster_profile': {
          'id': job['posted_by'],
          'username': job['poster_username'],
          'full_name': job['poster_full_name'],
          'avatar_url': job['poster_avatar_url'],
        },
      };


      return jobWithProfile;
    } catch (e) {
      return null;
    }
  }

  // Apply for a job
  Future<bool> applyForJob({
    required String jobId,
    required String applicantId,
    String? resumeUrl,
    String? coverLetter,
  }) async {
    try {
      final response = await _client
          .from('glibliojob_apply_now_detail')
          .insert({
            'job_id': jobId,
            'applicant_id': applicantId,
            'resume_url': resumeUrl,
            'cover_letter': coverLetter,
          })
          .select();

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Check if user already applied for a job
  Future<bool> hasUserAppliedForJob({
    required String jobId,
    required String applicantId,
  }) async {
    try {
      final response = await _client
          .from('glibliojob_apply_now_detail')
          .select('id')
          .eq('job_id', jobId)
          .eq('applicant_id', applicantId);

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get user's applications
  Future<List<Map<String, dynamic>>> getUserApplications(String userId) async {
    try {
      final response = await _client
          .from('glibliojob_apply_now_detail')
          .select('''
            *,
            glibliojob_job_details(*)
          ''')
          .eq('applicant_id', userId)
          .order('applied_at', ascending: false);

      if (response != null) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // Post a new job
  Future<Map<String, dynamic>?> postJob({
    required String title,
    required String companyName,
    required String location,
    required String jobType,
    String workMode = 'Remote',
    dynamic salaryRangeMin,
    dynamic salaryRangeMax,
    required String description,
    required List<String> requirements,
    required String experienceLevel,
    String? applicationDeadline,
    required String postedBy,
    bool isRemote = false,
    bool isActive = true,
    String currency = 'NGN',
  }) async {
    try {
      // Prepare the job data
      final jobData = {
        'title': title,
        'company_name': companyName,
        'location': location,
        'job_type': jobType,
        'work_mode': workMode,
        'salary_range_min': salaryRangeMin,
        'salary_range_max': salaryRangeMax,
        'currency': currency,
        'description': description,
        'requirements': requirements,
        'experience_level': experienceLevel,
        'application_deadline': applicationDeadline,
        'posted_by': postedBy,
        'remote_friendly': isRemote,
        'is_active': isActive,
      };

      final response = await _client
          .from('glibliojob_job_details')
          .insert(jobData)
          .select()
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  // Get jobs posted by a specific user
  Future<List<Map<String, dynamic>>> getJobsPostedByUser(String userId) async {
    try {
      final response = await _client
          .from('glibliojob_job_details')
          .select('''
            *
          ''')
          .eq('posted_by', userId)
          .order('created_at', ascending: false);

      if (response != null) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // Get profile information by user ID
  Future<Map<String, dynamic>?> getProfileById(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('id, username, full_name, avatar_url, bio')
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }
}