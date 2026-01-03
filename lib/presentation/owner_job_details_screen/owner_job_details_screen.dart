import 'package:flutter/material.dart';

class OwnerJobDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const OwnerJobDetailsScreen({super.key, required this.job});

  @override
  State<OwnerJobDetailsScreen> createState() => _OwnerJobDetailsScreenState();
}

class _OwnerJobDetailsScreenState extends State<OwnerJobDetailsScreen> {
  bool _isExpanded = false;

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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      _buildInfoChip(Icons.access_time, widget.job['job_type']?.toString().toUpperCase().replaceAll('-', ' ') ?? 'N/A'),
                      _buildInfoChip(Icons.wifi, widget.job['work_mode'] ?? 'On-site'),
                      _buildInfoChip(Icons.attach_money, widget.job['salary_range_min'] != null && widget.job['salary_range_max'] != null
                          ? '₦${widget.job['salary_range_min'].toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} - ₦${widget.job['salary_range_max'].toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'
                          : 'Salary not specified'),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Posted ${_formatPostedTime(widget.job['created_at'])}',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),

            Divider(height: 1, thickness: 1),

            // Company Information
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Company Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildInfoRow(Icons.business, widget.job['company_name'] ?? 'N/A'),
                  SizedBox(height: 8),
                  _buildInfoRow(Icons.location_on, widget.job['location'] ?? 'N/A'),
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
                    widget.job['description'] + '\n\n' +
                    'We are looking for a talented professional to join our team. The ideal candidate will have strong technical skills and the ability to work collaboratively in a fast-paced environment.\n\n' +
                    'This is a great opportunity to work on cutting-edge projects and make a real impact.',
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

            // Skills/Requirements
            if (skills.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requirements',
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
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            skill,
                            style: TextStyle(
                              fontSize: 12,
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
            ],

            SizedBox(height: 16),
          ],
        ),
      ),
    );
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
          Icon(icon, size: 14, color: Colors.grey[600]),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600]),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  String _formatPostedTime(String? createdAt) {
    if (createdAt == null) return 'N/A';

    try {
      final date = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inMinutes}m ago';
      }
    } catch (e) {
      return 'N/A';
    }
  }
}