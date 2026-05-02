library;

import 'package:flutter/material.dart';

/// Job category filters for the Job Portal.
enum JobCategory {
  all('All', Icons.dashboard_outlined),
  engineering('Engineering', Icons.code_outlined),
  design('Design', Icons.palette_outlined),
  marketing('Marketing', Icons.campaign_outlined),
  sales('Sales', Icons.trending_up_outlined),
  finance('Finance', Icons.account_balance_outlined),
  product('Product', Icons.inventory_2_outlined),
  data('Data', Icons.storage_outlined),
  operations('Operations', Icons.settings_outlined),
  hr('HR', Icons.people_outline);

  final String label;
  final IconData icon;

  const JobCategory(this.label, this.icon);

  /// Match a category string from the API to a [JobCategory].
  static JobCategory fromApi(String? value) {
    if (value == null || value.isEmpty) return JobCategory.all;
    return JobCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => JobCategory.all,
    );
  }
}

/// Employment type for a job listing.
enum JobType {
  all('All', ''),
  fullTime('Full-time', 'full-time'),
  partTime('Part-time', 'part-time'),
  contract('Contract', 'contract'),
  internship('Internship', 'internship'),
  freelance('Freelance', 'freelance');

  final String label;
  final String apiValue;

  const JobType(this.label, this.apiValue);

  /// Match a type string from the API to a [JobType].
  static JobType fromApi(String? value) {
    if (value == null || value.isEmpty) return JobType.fullTime;
    return JobType.values.firstWhere(
      (t) => t.apiValue == value,
      orElse: () => JobType.fullTime,
    );
  }
}

/// A single job listing from the /api/jobs endpoint.
class Job {
  final String id;
  final String title;
  final String company;
  final String? companyLogo;
  final String? location;
  final JobType type;
  final JobCategory category;
  final bool isRemote;
  final String? salary;
  final String? description;
  final List<String> requirements;
  final List<String> skills;
  final int applicationCount;
  final String? postedAt;
  final String? applyUrl;
  final bool isActive;

  const Job({
    required this.id,
    required this.title,
    required this.company,
    this.companyLogo,
    this.location,
    this.type = JobType.fullTime,
    this.category = JobCategory.all,
    this.isRemote = false,
    this.salary,
    this.description,
    this.requirements = const [],
    this.skills = const [],
    this.applicationCount = 0,
    this.postedAt,
    this.applyUrl,
    this.isActive = true,
  });

  /// Build a [Job] from an API JSON map.
  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: json['title'] as String? ?? '',
      company: json['company'] as String? ?? '',
      companyLogo: json['companyLogo'] as String?,
      location: json['location'] as String?,
      type: JobType.fromApi(json['type'] as String?),
      category: JobCategory.fromApi(json['category'] as String?),
      isRemote: json['isRemote'] as bool? ?? false,
      salary: json['salary'] as String?,
      description: json['description'] as String?,
      requirements: json['requirements'] != null
          ? List<String>.from(json['requirements'])
          : [],
      skills: json['skills'] != null ? List<String>.from(json['skills']) : [],
      applicationCount:
          (json['applicationCount'] ?? json['application_count'] ?? 0) as int,
      postedAt: (json['postedAt'] ?? json['posted_at']) as String?,
      applyUrl: (json['applyUrl'] ?? json['apply_url']) as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
