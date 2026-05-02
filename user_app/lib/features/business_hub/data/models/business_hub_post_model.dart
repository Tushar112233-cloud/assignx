library;

import 'package:flutter/material.dart';

/// Funding stage filter for investors.
enum FundingStage {
  all('All', 'all', Icons.dashboard_outlined),
  preSeed('Pre-Seed', 'pre-seed', Icons.rocket_launch_outlined),
  seed('Seed', 'seed', Icons.spa_outlined),
  seriesA('Series A', 'series-a', Icons.trending_up),
  seriesB('Series B', 'series-b', Icons.show_chart),
  seriesC('Series C', 'series-c', Icons.stacked_line_chart),
  growth('Growth', 'growth', Icons.auto_graph);

  final String label;
  final String apiValue;
  final IconData icon;

  const FundingStage(this.label, this.apiValue, this.icon);

  /// Parse a funding stage from an API string value.
  static FundingStage fromApi(String value) {
    return FundingStage.values.firstWhere(
      (s) => s.apiValue == value,
      orElse: () => FundingStage.seed,
    );
  }
}

/// Common investor sectors.
class InvestorSectors {
  InvestorSectors._();

  static const String fintech = 'Fintech';
  static const String healthtech = 'Healthtech';
  static const String edtech = 'Edtech';
  static const String saas = 'SaaS';
  static const String ecommerce = 'E-commerce';
  static const String ai = 'AI/ML';
  static const String cleantech = 'Cleantech';
  static const String deeptech = 'Deeptech';
  static const String consumer = 'Consumer';
  static const String enterprise = 'Enterprise';
  static const String logistics = 'Logistics';
  static const String agritech = 'Agritech';

  static const List<String> all = [
    fintech,
    healthtech,
    edtech,
    saas,
    ecommerce,
    ai,
    cleantech,
    deeptech,
    consumer,
    enterprise,
    logistics,
    agritech,
  ];
}

/// Ticket size range for an investor.
class TicketSize {
  final double min;
  final double max;
  final String currency;

  const TicketSize({
    required this.min,
    required this.max,
    this.currency = 'USD',
  });

  factory TicketSize.fromJson(Map<String, dynamic> json) {
    return TicketSize(
      min: (json['min'] as num?)?.toDouble() ?? 0,
      max: (json['max'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
    );
  }

  /// Format the ticket size as a human-readable range.
  String get formatted {
    final symbol = _currencySymbol;
    return '$symbol${_formatAmount(min)} - $symbol${_formatAmount(max)}';
  }

  String get _currencySymbol {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'INR':
        return '\u20B9';
      case 'EUR':
        return '\u20AC';
      case 'GBP':
        return '\u00A3';
      default:
        return '$currency ';
    }
  }

  static String _formatAmount(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(amount % 1000000000 == 0 ? 0 : 1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(amount % 1000000 == 0 ? 0 : 1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

/// Investor model from the /api/investors endpoint.
class Investor {
  final String id;
  final String name;
  final String firm;
  final String? description;
  final String? logoUrl;
  final List<FundingStage> fundingStages;
  final List<String> sectors;
  final TicketSize? ticketSize;
  final List<String> portfolioCompanies;
  final String? contactEmail;
  final String? linkedinUrl;
  final String? websiteUrl;
  final bool isActive;
  final String? location;

  const Investor({
    required this.id,
    required this.name,
    required this.firm,
    this.description,
    this.logoUrl,
    this.fundingStages = const [],
    this.sectors = const [],
    this.ticketSize,
    this.portfolioCompanies = const [],
    this.contactEmail,
    this.linkedinUrl,
    this.websiteUrl,
    this.isActive = true,
    this.location,
  });

  factory Investor.fromJson(Map<String, dynamic> json) {
    // Handle both camelCase and snake_case field names
    final stagesRaw = json['fundingStages'] ?? json['funding_stages'];
    final stages = stagesRaw is List
        ? stagesRaw.map((s) => FundingStage.fromApi(s as String)).toList()
        : <FundingStage>[];

    final sectorsRaw = json['sectors'];
    final sectors = sectorsRaw is List
        ? sectorsRaw.cast<String>().toList()
        : <String>[];

    final ticketRaw = json['ticketSize'] ?? json['ticket_size'];
    final ticketSize = ticketRaw is Map<String, dynamic>
        ? TicketSize.fromJson(ticketRaw)
        : null;

    final portfolioRaw =
        json['portfolioCompanies'] ?? json['portfolio_companies'];
    final portfolio = portfolioRaw is List
        ? portfolioRaw.cast<String>().toList()
        : <String>[];

    return Investor(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      firm: (json['firm'] ?? '') as String,
      description: json['description'] as String?,
      logoUrl: (json['logoUrl'] ?? json['logo_url']) as String?,
      fundingStages: stages,
      sectors: sectors,
      ticketSize: ticketSize,
      portfolioCompanies: portfolio,
      contactEmail: (json['contactEmail'] ?? json['contact_email']) as String?,
      linkedinUrl: (json['linkedinUrl'] ?? json['linkedin_url']) as String?,
      websiteUrl: (json['websiteUrl'] ?? json['website_url']) as String?,
      isActive: (json['isActive'] ?? json['is_active'] ?? true) as bool,
      location: json['location'] as String?,
    );
  }

  /// Get the firm initial for avatar placeholder.
  String get firmInitial =>
      firm.isNotEmpty ? firm[0].toUpperCase() : '?';
}
