/// Root application widget for the DOER app.
///
/// This file contains the main [DoerApp] widget which serves as the root
/// of the widget tree and configures:
/// - Application title and branding
/// - Theme configuration (light and dark modes)
/// - Router configuration for navigation
/// - Debug banner visibility
///
/// ## Architecture
/// The app uses [ConsumerWidget] from Riverpod to access providers,
/// specifically the [appRouterProvider] for navigation configuration.
///
/// ## Theme Modes
/// Currently, the app is set to use light theme mode only ([ThemeMode.light]).
/// Dark theme support is available but not yet enabled by default.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

/// Root widget of the DOER app.
///
/// This widget configures the [MaterialApp.router] with:
/// - Application title: "DOER - Talent Connect"
/// - Theme configuration from [AppTheme]
/// - Navigation using go_router via [appRouterProvider]
///
/// ## Usage
/// This widget should be instantiated once and wrapped in a [ProviderScope]:
/// ```dart
/// runApp(
///   const ProviderScope(
///     child: DoerApp(),
///   ),
/// );
/// ```
///
/// ## Theme Configuration
/// - Light theme: [AppTheme.lightTheme]
/// - Dark theme: [AppTheme.darkTheme]
/// - Current mode: [ThemeMode.light]
///
/// ## Navigation
/// Uses declarative routing with go_router. The router configuration
/// is provided via [appRouterProvider] and handles:
/// - Route definitions
/// - Authentication guards
/// - Deep linking support
class DoerApp extends ConsumerWidget {
  /// Creates the root DOER application widget.
  const DoerApp({super.key});

  /// Builds the MaterialApp with router configuration.
  ///
  /// The [ref] parameter provides access to Riverpod providers,
  /// specifically used to watch the [appRouterProvider] for
  /// navigation configuration.
  ///
  /// @param context The build context
  /// @param ref The Riverpod widget reference for accessing providers
  /// @returns A configured [MaterialApp.router] widget
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'DOER - Talent Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
