import 'package:flutter/material.dart';

class ApplicationCardWidget extends StatelessWidget {
  final Map<String, dynamic> application;
  final VoidCallback onTap;

  const ApplicationCardWidget({
    super.key,
    required this.application,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = application['status'] as String;
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Applicant avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.network(
                    application['applicantAvatar'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person, color: Colors.grey[400]),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application['applicantName'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Applied for ${application['jobTitle']}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            // Cover letter preview
            Text(
              application['coverLetter'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            SizedBox(height: 12),
            // Skills
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: (application['skills'] as List<dynamic>)
                  .take(3)
                  .map((skill) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black87,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 12),
            // Footer
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.black54),
                SizedBox(width: 4),
                Text(
                  application['appliedDate'],
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                Spacer(),
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black54),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'reviewed':
        return Colors.blue;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'reviewed':
        return 'Reviewed';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }
}
