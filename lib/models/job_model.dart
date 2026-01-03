class Job {
  final String id;
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
  final String? externalLink;
  final String? posterId;
  final String? posterName;
  final String? posterUsername;
  final String? posterAvatar;
  final String? posterBio;
  final List<String>? posterSkills;

  Job({
    required this.id,
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
    this.externalLink,
    this.posterId,
    this.posterName,
    this.posterUsername,
    this.posterAvatar,
    this.posterBio,
    this.posterSkills,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    // Get poster profile data
    final posterProfile = json['poster_profile'] as Map<String, dynamic>?;
    
    return Job(
      id: json['id'] ?? '',
      title: json['title'] ?? 'N/A',
      company: json['company_name'] ?? json['company'] ?? 'N/A',
      location: json['location'] ?? 'N/A',
      jobType: _formatJobType(json['job_type'] ?? json['jobType'] ?? 'N/A'),
      workMode: (json['remote_friendly'] == true || json['workMode'] == 'Remote') ? 'Remote' : 'On-site',
      salaryRange: _formatSalaryRange(json['salary_range_min'], json['salary_range_max'], json['currency'] ?? 'NGN'),
      description: json['description'] ?? 'No description available',
      skills: _parseSkills(json['requirements'] ?? json['skills'] ?? []),
      postedTime: _formatPostedTime(json['created_at'] ?? json['postedTime']),
      isFeatured: json['is_active'] ?? json['isFeatured'] ?? false,
      externalLink: json['external_link'] ?? json['externalLink'],
      posterId: json['posted_by'] ?? json['posterId'],
      posterName: posterProfile?['full_name'] ?? json['poster_full_name'] ?? json['posterName'] ?? 'Job Poster',
      posterUsername: '@${posterProfile?['username'] ?? json['poster_username'] ?? json['posterUsername'] ?? 'jobposter'}',
      posterAvatar: posterProfile?['avatar_url'] ?? json['poster_avatar_url'] ?? json['posterAvatar'] ?? 'https://via.placeholder.com/150',
      posterBio: posterProfile?['bio'] ?? json['posterBio'] ?? 'Job poster on Gliblio Jobs',
      posterSkills: List<String>.from(posterProfile?['skills'] ?? json['posterSkills'] ?? []),
    );
  }

  static String _formatSalaryRange(dynamic min, dynamic max, [String currency = 'NGN']) {
    if (min == null && max == null) return 'Salary not specified';
    
    String minStr = '';
    String maxStr = '';
    String currencySymbol = _getCurrencySymbol(currency);
    
    if (min != null) {
      double minVal = (min is int) ? min.toDouble() : min;
      minStr = '$currencySymbol${minVal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    }
    
    if (max != null) {
      double maxVal = (max is int) ? max.toDouble() : max;
      maxStr = '$currencySymbol${maxVal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    }
    
    if (minStr.isNotEmpty && maxStr.isNotEmpty) {
      return '$minStr - $maxStr';
    } else if (minStr.isNotEmpty) {
      return 'From $minStr';
    } else if (maxStr.isNotEmpty) {
      return 'Up to $maxStr';
    }
    
    return 'Salary not specified';
  }
  
  static String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return r'$';
      case 'NGN':
        return r'₦';
      case 'EUR':
        return r'€';
      case 'GBP':
        return r'£';
      default:
        return currency;
    }
  }

  static String _formatNumber(dynamic num) {
    if (num == null) return '0';
    return num.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  static String _formatPostedTime(String? createdAt) {
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

  static List<String> _parseSkills(dynamic requirements) {
    if (requirements is List) {
      return requirements.cast<String>();
    }
    if (requirements is String) {
      // If it's a single string, split by common delimiters
      return requirements.split(',').map((s) => s.trim()).toList();
    }
    return [];
  }

  static String _formatJobType(String jobType) {
    // Convert database format (e.g. 'full-time') to UI format (e.g. 'Full-time')
    if (jobType.isEmpty) return 'N/A';
    
    // Split by hyphen and capitalize first letter of each word
    final parts = jobType.split('-');
    final formattedParts = parts.map((part) {
      if (part.isEmpty) return part;
      return part[0].toUpperCase() + part.substring(1).toLowerCase();
    });
    
    return formattedParts.join('-');
  }
}