import 'package:flutter/material.dart';

class JobCardWidget extends StatelessWidget {
  final String title;
  final String company;
  final String location;
  final String jobType;
  final String workMode;
  final String salaryRange;
  final String description;
  final List<String> skills;
  final String postedTime;
  final bool isFeatured;
  final VoidCallback onViewDetails;
  final VoidCallback onApply;
  final VoidCallback onSave;

  const JobCardWidget({
    super.key,
    required this.title,
    required this.company,
    required this.location,
    required this.jobType,
    required this.workMode,
    required this.salaryRange,
    required this.description,
    required this.skills,
    required this.postedTime,
    this.isFeatured = false,
    required this.onViewDetails,
    required this.onApply,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFeatured ? Color(0xFF00C9A7) : Color(0xFFE5E5E5),
          width: isFeatured ? 2 : 1,
        ),
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
          // Featured badge
          if (isFeatured)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFFE6F9F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: Color(0xFF00C9A7), size: 16),
                  SizedBox(width: 4),
                  Text(
                    'FEATURED',
                    style: TextStyle(
                      color: Color(0xFF00C9A7),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

          // Main content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company logo and title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company logo placeholder
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1549924231-f129b911e442?w=200&h=200&fit=crop',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.business, color: Colors.grey[400]),
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
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            company,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Save button
                    IconButton(
                      onPressed: onSave,
                      icon: Icon(Icons.bookmark_border),
                      color: Colors.black54,
                      iconSize: 24,
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Location, job type, work mode
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.black54),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.access_time, size: 16, color: Colors.black54),
                    SizedBox(width: 4),
                    Text(
                      jobType,
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),

                SizedBox(height: 8),

                // Work mode
                Row(
                  children: [
                    Icon(Icons.wifi, size: 16, color: Colors.black54),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        workMode,
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Salary
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 18, color: Colors.black),
                    Expanded(
                      child: Text(
                        salaryRange,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Description
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: 12),

                // Skills
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...skills.take(3).map((skill) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          skill,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }),
                    if (skills.length > 3)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '+${skills.length - 3} more',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 16),

                // Posted time and action buttons
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Posted $postedTime',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ),
                    // View Details button
                    OutlinedButton(
                      onPressed: onViewDetails,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.black, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size(0, 36),
                      ),
                      child: Text(
                        'View Details',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    // Apply button
                    ElevatedButton(
                      onPressed: onApply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        minimumSize: Size(0, 36),
                        elevation: 0,
                      ),
                      child: Text(
                        'Apply Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
