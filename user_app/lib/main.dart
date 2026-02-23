import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'app.dart';
import 'core/config/api_config.dart';
import 'core/config/razorpay_config.dart';
import 'core/config/supabase_config.dart';
import 'core/services/notification_service.dart';

/// Global logger instance for error tracking
final _logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

/// Application entry point.
///
/// Initializes services and runs the app with global error handling.
void main() async {
  // Wrap entire app in error zone for uncaught async errors
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Set up Flutter error handler for synchronous errors
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        _logger.e(
          'Flutter Error',
          error: details.exception,
          stackTrace: details.stack,
        );
        // In production, send to crash reporting service (e.g., Crashlytics)
        if (kReleaseMode) {
          // TODO: Send to Crashlytics or other crash reporting service
          // FirebaseCrashlytics.instance.recordFlutterError(details);
        }
      };

      // Handle errors in the framework itself
      PlatformDispatcher.instance.onError = (error, stack) {
        _logger.e('Platform Error', error: error, stackTrace: stack);
        return true;
      };

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
          statusBarBrightness: Brightness.light,
        ),
      );

      // Initialize Firebase (Optional: for future crash reporting)
      try {
        await Firebase.initializeApp();
        _logger.i('Firebase initialized successfully');
      } catch (e) {
        _logger.w('Firebase initialization skipped (not configured): $e');
        // Firebase is optional - app can run without it
      }

      // Validate and initialize Supabase
      try {
        SupabaseConfig.validateConfiguration();
        await SupabaseConfig.initialize();
        _logger.i('Supabase initialized successfully');
      } catch (e) {
        _logger.w('Supabase initialization failed: $e');
        _logger.w('App will run in demo mode without backend connectivity');
        // App can run in demo mode without Supabase
      }

      // Validate API configuration (required for payments)
      try {
        ApiConfig.validateConfiguration();
        _logger.i('API configuration validated: ${ApiConfig.baseUrl}');
      } catch (e) {
        _logger.w('API configuration missing: $e');
        _logger.w('Payment features will be unavailable');
        // App can run without payments in limited mode
      }

      // Validate Razorpay configuration (required for payments)
      try {
        RazorpayConfig.validateConfiguration();
        _logger.i('Razorpay configured (test mode: ${RazorpayConfig.isTestMode})');
      } catch (e) {
        _logger.w('Razorpay configuration missing: $e');
        _logger.w('Payment features will be unavailable');
        // App can run without payments in limited mode
      }

      // Initialize notification service (requires Firebase)
      try {
        await NotificationService().initialize();
        _logger.i('Notification service initialized successfully');
      } catch (e) {
        _logger.w('Notification service initialization failed (requires Firebase): $e');
        // Push notifications require Firebase - app can run without them
      }

      // Run the app
      runApp(
        const ProviderScope(
          child: UserApp(),
        ),
      );
    },
    (error, stackTrace) {
      // Handle uncaught async errors
      _logger.e('Uncaught async error', error: error, stackTrace: stackTrace);
      if (kReleaseMode) {
        // TODO: Send to crash reporting service
        // FirebaseCrashlytics.instance.recordError(error, stackTrace);
      }
    },
  );
}
