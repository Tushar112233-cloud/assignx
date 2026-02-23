import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/config/env.dart';
import 'core/network/supabase_client.dart';

/// Application entry point.
///
/// Initializes services and runs the app.
void main() async {
  // Ensure Flutter bindings are initialized
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

  // Initialize Supabase - required for app to function
  if (!Env.isConfigured) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Supabase configuration missing.\n\n'
                'Please provide SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }

  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('Error initializing Supabase: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Failed to connect to backend.\n\nError: $e',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }

  // Run the app with Riverpod
  runApp(
    const ProviderScope(
      child: AdminXApp(),
    ),
  );
}
