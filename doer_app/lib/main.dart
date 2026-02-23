/// Main entry point for the DOER application.
///
/// This file contains the application bootstrap logic including:
/// - Flutter bindings initialization
/// - System UI configuration (orientation, status bar)
/// - Supabase backend initialization
/// - Provider scope setup for state management
///
/// ## Application Flow
/// 1. Initialize Flutter bindings
/// 2. Lock screen orientation to portrait mode
/// 3. Configure system UI overlays (transparent status bar)
/// 4. Initialize Supabase client for backend connectivity
/// 5. Launch the app wrapped in Riverpod [ProviderScope]
///
/// ## Example
/// The app is launched via standard Flutter entry:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await SupabaseConfig.initialize();
///   runApp(const ProviderScope(child: DoerApp()));
/// }
/// ```
///
/// ## Dependencies
/// - `flutter/material.dart` - Material Design widgets
/// - `flutter/services.dart` - Platform channel services
/// - `flutter_riverpod` - State management
/// - `supabase_flutter` - Backend as a service (via SupabaseConfig)
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/supabase_config.dart';

/// Entry point of the DOER app.
///
/// This function performs the following initialization steps:
/// 1. Ensures Flutter bindings are initialized for async operations
/// 2. Sets preferred device orientations to portrait only
/// 3. Configures system UI overlay styles for a polished appearance
/// 4. Initializes the Supabase backend connection
/// 5. Runs the application with Riverpod state management
///
/// ## Throws
/// - [StateError] if Supabase configuration is missing (via [SupabaseConfig.initialize])
///
/// ## Note
/// This function is marked `async` because it awaits platform channel
/// operations and backend initialization before running the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Supabase
  await SupabaseConfig.initialize();

  // Run the app with Riverpod
  runApp(
    const ProviderScope(
      child: DoerApp(),
    ),
  );
}
