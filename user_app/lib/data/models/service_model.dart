import 'package:flutter/material.dart';

/// Service types available in the app.
enum ServiceType {
  projectSupport,
  aiPlagReport,
  consultDoctor,
  referenceGenerator,
}

/// Service model for home grid.
class ServiceItem {
  final ServiceType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final bool isAvailable;
  final String? badge;

  const ServiceItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    this.isAvailable = true,
    this.badge,
  });

  /// Get all services for home grid.
  static List<ServiceItem> get homeServices => [
    const ServiceItem(
      type: ServiceType.projectSupport,
      title: 'Project Support',
      subtitle: 'Get expert help',
      icon: Icons.assignment_outlined,
      route: '/add-project/new',
    ),
    const ServiceItem(
      type: ServiceType.aiPlagReport,
      title: 'AI/Plag Report',
      subtitle: 'Check originality',
      icon: Icons.verified_outlined,
      route: '/add-project/report',
    ),
    const ServiceItem(
      type: ServiceType.consultDoctor,
      title: 'Consult Expert',
      subtitle: 'Coming soon',
      icon: Icons.support_agent_outlined,
      route: '/marketplace',
      isAvailable: false,
      badge: 'Soon',
    ),
    const ServiceItem(
      type: ServiceType.referenceGenerator,
      title: 'References',
      subtitle: 'Generate citations',
      icon: Icons.format_quote_outlined,
      route: '/add-project/proofread',
      badge: 'FREE',
    ),
  ];
}
