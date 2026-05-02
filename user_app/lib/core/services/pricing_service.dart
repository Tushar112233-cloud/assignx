import 'dart:convert';
import '../api/api_client.dart';

/// Pricing configuration fetched from the backend (admin-configurable).
class PricingConfig {
  final double assignmentPerWord;
  final double websitePerPage;
  final double appSinglePlatform;
  final double appBothPlatforms;
  final double consultancy30min;
  final double consultancy1hr;
  final double consultancy2hr;
  final double gstPercent;
  final double urgencyStandard;
  final double urgencyExpress;
  final double urgencyUrgent;
  final double websitePerFeature;
  final double appPerFeature;
  final double turnitinAiDetection;
  final double turnitinPlagiarismCheck;
  final double turnitinCompleteReport;

  const PricingConfig({
    this.assignmentPerWord = 0.1,
    this.websitePerPage = 1000,
    this.appSinglePlatform = 2500,
    this.appBothPlatforms = 4000,
    this.consultancy30min = 50,
    this.consultancy1hr = 80,
    this.consultancy2hr = 150,
    this.gstPercent = 10,
    this.urgencyStandard = 1,
    this.urgencyExpress = 1.5,
    this.urgencyUrgent = 3,
    this.websitePerFeature = 500,
    this.appPerFeature = 1000,
    this.turnitinAiDetection = 10,
    this.turnitinPlagiarismCheck = 99,
    this.turnitinCompleteReport = 129,
  });

  factory PricingConfig.fromJson(Map<String, dynamic> json) {
    final project = json['project_pricing'] as Map<String, dynamic>? ?? {};
    final quote = json['quote_pricing'] as Map<String, dynamic>? ?? {};
    final turnitin = json['turnitin_pricing'] as Map<String, dynamic>? ?? {};

    return PricingConfig(
      assignmentPerWord: (project['assignment_per_word'] ?? 0.1).toDouble(),
      websitePerPage: (project['website_per_page'] ?? 1000).toDouble(),
      appSinglePlatform: (project['app_single_platform'] ?? 2500).toDouble(),
      appBothPlatforms: (project['app_both_platforms'] ?? 4000).toDouble(),
      consultancy30min: (project['consultancy_30min'] ?? 50).toDouble(),
      consultancy1hr: (project['consultancy_1hr'] ?? 80).toDouble(),
      consultancy2hr: (project['consultancy_2hr'] ?? 150).toDouble(),
      gstPercent: (project['gst_percent'] ?? 10).toDouble(),
      urgencyStandard: (project['urgency_standard'] ?? 1).toDouble(),
      urgencyExpress: (project['urgency_express'] ?? 1.5).toDouble(),
      urgencyUrgent: (project['urgency_urgent'] ?? 3).toDouble(),
      websitePerFeature: (quote['website_per_feature'] ?? 500).toDouble(),
      appPerFeature: (quote['app_per_feature'] ?? 1000).toDouble(),
      turnitinAiDetection: (turnitin['ai_detection'] ?? 10).toDouble(),
      turnitinPlagiarismCheck: (turnitin['plagiarism_check'] ?? 99).toDouble(),
      turnitinCompleteReport: (turnitin['complete_report'] ?? 129).toDouble(),
    );
  }
}

/// Service to fetch and cache pricing from the API.
class PricingService {
  static PricingConfig? _cached;

  static Future<PricingConfig> fetch() async {
    if (_cached != null) return _cached!;
    try {
      final response = await ApiClient.get('/resources/pricing');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _cached = PricingConfig.fromJson(data);
        return _cached!;
      }
    } catch (_) {
      // Fall back to defaults
    }
    return const PricingConfig();
  }

  /// Force refresh from API.
  static Future<PricingConfig> refresh() async {
    _cached = null;
    return fetch();
  }

  /// Get cached config or defaults (synchronous).
  static PricingConfig get config => _cached ?? const PricingConfig();
}
