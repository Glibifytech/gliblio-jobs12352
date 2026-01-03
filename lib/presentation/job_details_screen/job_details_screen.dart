import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  List<String> _parseSkills(dynamic requirements) {
    if (requirements is List) {
      return requirements.cast<String>();
    }
    if (requirements is String) {
      // If it's a single string, split by common delimiters
      return requirements.split(',').map((s) => s.trim()).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    
    final skills = _parseSkills(widget.job['requirements'] ?? widget.job['skills'] ?? []);
    
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
          'Job Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark_border, color: Colors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Saved ${widget.job['title']}')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Poster Profile Section
            _buildPosterProfileSection(),

            Divider(height: 1, thickness: 1, color: Colors.grey[300]),

            // Company Information Section  
            _buildCompanySection(),
            
            Divider(height: 1, thickness: 1, color: Colors.grey[300]),
            
            // Job title
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.job['title'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(Icons.access_time, widget.job['jobType']),
                      _buildInfoChip(Icons.wifi, widget.job['workMode']),
                      _buildInfoChip(Icons.attach_money, widget.job['salaryRange']),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Posted ${widget.job['postedTime']}',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),

            Divider(height: 1, thickness: 1),

            // Job description
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Job Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '''${widget.job['description']}

We are looking for a talented professional to join our team. The ideal candidate will have strong technical skills and the ability to work collaboratively in a fast-paced environment.

This is a great opportunity to work on cutting-edge projects and make a real impact.''',
                    maxLines: _isExpanded ? null : 4,
                    overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Text(
                      _isExpanded ? 'Read less' : 'Read more',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, thickness: 1),

            // External application link
            if (widget.job['externalLink'] != null && widget.job['externalLink'].toString().isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'External Application',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 12),
                    InkWell(
                      onTap: () => _launchUrl(widget.job['externalLink']),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.link, color: Theme.of(context).primaryColor, size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Apply on company website',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    widget.job['externalLink'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.open_in_new, color: Theme.of(context).primaryColor, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, thickness: 1),
            ],

            // Required skills
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Required Skills',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
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

            SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Share job
                    final jobText = '''${widget.job['title']} at ${widget.job['company']}
${widget.job['location']} • ${widget.job['jobType']}
Salary: ${widget.job['salaryRange']}

Apply now on Gliblio Jobs!''';
                    
                    Clipboard.setData(ClipboardData(text: jobText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Job details copied to clipboard')),
                    );
                  },
                  icon: Icon(Icons.share, size: 18),
                  label: Text('Share'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/apply-job',
                      arguments: widget.job,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: Text(
                    'Apply',
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
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // Job Poster Profile Section (like design marketplace)
  Widget _buildPosterProfileSection() {
    final posterName = widget.job['posterName'] as String?;
    final posterUsername = widget.job['posterUsername'] as String?;
    final posterAvatar = widget.job['posterAvatar'] as String?;
    final posterId = widget.job['posterId'] as String?;
    
    
    if (posterName == null || posterName.isEmpty || posterName == 'Job Poster') {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Posted by',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              
              if (posterId != null) {
                Navigator.pushNamed(
                  context,
                  '/job-poster-profile',
                  arguments: {
                    'posterId': posterId,
                    'posterName': posterName,
                    'posterUsername': posterUsername?.replaceAll('@', '') ?? '',
                    'posterAvatar': posterAvatar,
                    'posterBio': widget.job['posterBio'],
                    'posterSkills': widget.job['posterSkills'] ?? [],
                  },
                );
              }
            },
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: posterAvatar != null && posterAvatar.isNotEmpty
                      ? Image.network(
                          posterAvatar,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.person, color: Colors.grey[400], size: 24),
                            );
                          },
                        )
                      : Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.person, color: Colors.grey[400], size: 24),
                        ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        posterName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        posterUsername ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Company Information Section
  Widget _buildCompanySection() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.business, color: Theme.of(context).primaryColor, size: 20),
            SizedBox(width: 8),
            Text(
              widget.job['company_name'] ?? widget.job['company'] ?? 'N/A',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
