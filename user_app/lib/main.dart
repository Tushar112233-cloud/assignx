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
        if (kReleaseMode) {
          // TODO: Send to Crashlytics or other crash reporting service
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
      }

      // Initialize API configuration
      try {
        await ApiConfig.initialize();
        _logger.i('API client initialized: ${ApiConfig.baseUrl}');
      } catch (e) {
        _logger.w('API initialization failed: $e');
        _logger.w('App will run in demo mode without backend connectivity');
      }

      // Validate Razorpay configuration (required for payments)
      try {
        RazorpayConfig.validateConfiguration();
        _logger.i('Razorpay configured (test mode: ${RazorpayConfig.isTestMode})');
      } catch (e) {
        _logger.w('Razorpay configuration missing: $e');
        _logger.w('Payment features will be unavailable');
      }

      // Initialize notification service (requires Firebase)
      try {
        await NotificationService().initialize();
        _logger.i('Notification service initialized successfully');
      } catch (e) {
        _logger.w('Notification service initialization failed (requires Firebase): $e');
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
      }
    },
  );
}
