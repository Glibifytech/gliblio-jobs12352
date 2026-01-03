import 'package:flutter/material.dart';
import '../../repositories/jobs_repository.dart';
import '../../widgets/custom_loading.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({Key? key}) : super(key: key);

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skillsController = TextEditingController();
  final _externalLinkController = TextEditingController();
  
  String _selectedJobType = 'Full-time';
  String _selectedWorkMode = 'Remote';
  String _selectedCurrency = 'NGN';
  final List<String> _jobTypes = ['Full-time', 'Part-time', 'Contract', 'Internship'];
  final List<String> _workModes = ['Remote', 'Hybrid', 'On-site'];
  final List<String> _currencies = ['NGN', 'USD', 'EUR', 'GBP'];
  
  final JobsRepository _jobsRepository = JobsRepository();
  bool _isPostingJob = false;

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _descriptionController.dispose();
    _skillsController.dispose();
    _externalLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          'Post a Job',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Job Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),

                    _buildTextField(
                      controller: _jobTitleController,
                      label: 'Job Title',
                      hint: 'e.g. Senior Flutter Developer',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter job title';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 16),

                    _buildTextField(
                      controller: _companyController,
                      label: 'Company Name',
                      hint: 'e.g. Tech Innovations Inc',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter company name';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 16),

                    _buildTextField(
                      controller: _locationController,
                      label: 'Location',
                      hint: 'e.g. San Francisco, CA',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter location';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 16),

                    Text(
                      'Job Type',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedJobType,
                          isExpanded: true,
                          items: _jobTypes.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedJobType = newValue!;
                            });
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    Text(
                      'Work Mode',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedWorkMode,
                          isExpanded: true,
                          items: _workModes.map((String mode) {
                            return DropdownMenuItem<String>(
                              value: mode,
                              child: Text(mode),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedWorkMode = newValue!;
                            });
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    Text(
                      'Salary Range',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _salaryMinController,
                            label: 'Minimum',
                            hint: '80000',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _salaryMaxController,
                            label: 'Maximum',
                            hint: '120000',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    Text(
                      'Job Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),

                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Job Description',
                      hint: 'Describe the role, responsibilities, and requirements...',
                      maxLines: 6,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter job description';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 16),

                    _buildTextField(
                      controller: _skillsController,
                      label: 'Required Skills',
                      hint: 'e.g. Flutter, Dart, Firebase, REST APIs (comma separated)',
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter required skills';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 16),

                    _buildTextField(
                      controller: _externalLinkController,
                      label: 'External Application Link (Optional)',
                      hint: 'https://careers.company.com/apply',
                      keyboardType: TextInputType.url,
                    ),

                    SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
          if (_isPostingJob)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CustomLoading(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isPostingJob ? null : _submitJob,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isPostingJob 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.5) 
                : Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
            ),
            child: _isPostingJob
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                )
              : Text(
                  'Post Job on Gliblio Jobs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  void _submitJob() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isPostingJob = true;
      });
      
      try {
        // Get the current user
        final user = SupabaseService.instance.client.auth.currentUser;
        if (user == null) {
          _showErrorDialog('Please log in to post a job');
          setState(() {
            _isPostingJob = false;
          });
          return;
        }
        
        // Parse the skills from the input field
        final skillsText = _skillsController.text;
        final List<String> skills = skillsText.split(',').map((skill) => skill.trim()).toList();
        
        // Post the job
        final result = await _jobsRepository.postJob(
          title: _jobTitleController.text,
          companyName: _companyController.text,
          location: _locationController.text,
          jobType: _selectedJobType.toLowerCase().replaceAll(' ', '-'),
          workMode: _selectedWorkMode,
          salaryRangeMin: double.tryParse(_salaryMinController.text),
          salaryRangeMax: double.tryParse(_salaryMaxController.text),
          description: _descriptionController.text,
          requirements: skills,
          experienceLevel: 'mid', // Default experience level
          postedBy: user.id,
          isRemote: _selectedWorkMode == 'Remote',
          isActive: true,
          currency: _selectedCurrency,
        );
        
        setState(() {
          _isPostingJob = false;
        });
        
        if (result != null) {
          _showSuccessDialog();
        } else {
          _showErrorDialog('Failed to post job. Please try again.');
        }
      } catch (e) {
        setState(() {
          _isPostingJob = false;
        });
        _showErrorDialog('Error posting job: $e');
      }
    }
  }
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Success!'),
          ],
        ),
        content: Text(
          'Your job posting has been submitted successfully and will be reviewed shortly.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close post job screen
            },
            child: Text('OK', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Error'),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
