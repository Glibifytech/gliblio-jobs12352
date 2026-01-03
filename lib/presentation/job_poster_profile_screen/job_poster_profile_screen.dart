import 'package:flutter/material.dart';

class JobPosterProfileScreen extends StatelessWidget {
  final Map<String, dynamic> posterData;

  const JobPosterProfileScreen({super.key, required this.posterData});

  @override
  Widget build(BuildContext context) {
    final skills = List<String>.from(posterData['posterSkills'] ?? []);
    
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
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            
            // Avatar
            Center(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.network(
                      posterData['posterAvatar'] ?? '',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: Icon(Icons.person, size: 60, color: Colors.grey[400]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Name
            Text(
              posterData['posterName'] ?? 'Unknown',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            
            SizedBox(height: 4),
            
            // Username
            Text(
              posterData['posterUsername'] ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            
            SizedBox(height: 24),
            
            Divider(height: 1, thickness: 1),
            
            // Skills section
            if (skills.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skills',
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
                              fontSize: 14,
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
            
            // About section
            if (posterData['posterBio'] != null && posterData['posterBio'].toString().isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      posterData['posterBio'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
