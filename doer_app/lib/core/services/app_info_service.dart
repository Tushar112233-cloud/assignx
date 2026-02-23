/// Application information service.
///
/// This file provides access to application metadata such as version,
/// build number, package name, and app name. The information is fetched
/// from the platform using the `package_info_plus` plugin.
///
/// ## Features
/// - Async fetching of platform-specific app info
/// - Default fallback values when info is unavailable
/// - Formatted version strings for display
/// - Both async and sync provider access patterns
///
/// ## Usage
/// ```dart
/// // Async access (preferred for initial load)
/// final info = await ref.read(appInfoProvider.future);
/// print(info.fullVersion); // "1.0.0 (1)"
///
/// // Sync access (uses defaults while loading)
/// final info = ref.watch(appInfoSyncProvider);
/// print(info.displayVersion); // "Version 1.0.0"
/// ```
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// App information model containing version and build details.
///
/// Encapsulates all metadata about the application that can be
/// retrieved from the platform.
///
/// ## Properties
/// - [appName]: Display name of the application
/// - [packageName]: Unique package/bundle identifier
/// - [version]: Semantic version string (e.g., "1.0.0")
/// - [buildNumber]: Build/version code number (e.g., "1")
///
/// ## Usage
/// ```dart
/// final info = AppInfo(
///   appName: 'DOER',
///   packageName: 'com.assignx.doer',
///   version: '1.0.0',
///   buildNumber: '1',
/// );
///
/// print(info.fullVersion);    // "1.0.0 (1)"
/// print(info.displayVersion); // "Version 1.0.0"
/// ```
class AppInfo {
  /// The display name of the application.
  ///
  /// This is the user-facing name shown on the device.
  final String appName;

  /// The unique package identifier.
  ///
  /// On Android, this is the applicationId (e.g., "com.assignx.doer").
  /// On iOS, this is the bundle identifier.
  final String packageName;

  /// The semantic version string.
  ///
  /// Following semver format: major.minor.patch (e.g., "1.0.0").
  final String version;

  /// The build or version code number.
  ///
  /// An incrementing integer represented as a string.
  /// Used by app stores to determine update availability.
  final String buildNumber;

  /// Creates an [AppInfo] instance with the given details.
  ///
  /// @param appName Application display name
  /// @param packageName Package/bundle identifier
  /// @param version Semantic version string
  /// @param buildNumber Build number string
  const AppInfo({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
  });

  /// Default fallback values.
  ///
  /// Used when platform info cannot be retrieved.
  /// Returns a sensible default for the DOER app.
  ///
  /// ## Returns
  /// An [AppInfo] with default values:
  /// - appName: 'DOER'
  /// - packageName: 'com.assignx.doer'
  /// - version: '1.0.0'
  /// - buildNumber: '1'
  factory AppInfo.defaults() => const AppInfo(
        appName: 'DOER',
        packageName: 'com.assignx.doer',
        version: '1.0.0',
        buildNumber: '1',
      );

  /// Full version string (e.g., "1.0.0 (1)").
  ///
  /// Combines version and build number in a standard format.
  /// Useful for debugging and support screens.
  String get fullVersion => '$version ($buildNumber)';

  /// Display version (e.g., "Version 1.0.0").
  ///
  /// User-friendly version string with "Version" prefix.
  /// Suitable for settings screens and about pages.
  String get displayVersion => 'Version $version';
}

/// Provider that asynchronously fetches app info.
///
/// This provider retrieves application metadata from the platform
/// and caches it for subsequent access. If fetching fails, it
/// returns default values.
///
/// ## Usage
/// ```dart
/// // In a widget
/// final asyncInfo = ref.watch(appInfoProvider);
///
/// asyncInfo.when(
///   data: (info) => Text(info.displayVersion),
///   loading: () => CircularProgressIndicator(),
///   error: (e, s) => Text('Error loading version'),
/// );
///
/// // Direct await
/// final info = await ref.read(appInfoProvider.future);
/// ```
///
/// ## Error Handling
/// If [PackageInfo.fromPlatform] fails, returns [AppInfo.defaults].
final appInfoProvider = FutureProvider<AppInfo>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    return AppInfo(
      appName: info.appName,
      packageName: info.packageName,
      version: info.version,
      buildNumber: info.buildNumber,
    );
  } catch (e) {
    // Return defaults if package info fails
    return AppInfo.defaults();
  }
});

/// Synchronous provider that returns app info or defaults.
///
/// Use this when you need immediate access without async handling.
/// Returns the loaded info if available, otherwise returns defaults.
///
/// ## Usage
/// ```dart
/// // Always returns immediately (no loading state)
/// final info = ref.watch(appInfoSyncProvider);
/// Text(info.displayVersion);
/// ```
///
/// ## Behavior
/// - While [appInfoProvider] is loading: returns [AppInfo.defaults]
/// - After successful load: returns fetched [AppInfo]
/// - On error: returns [AppInfo.defaults]
final appInfoSyncProvider = Provider<AppInfo>((ref) {
  final asyncValue = ref.watch(appInfoProvider);
  return asyncValue.when(
    data: (info) => info,
    loading: () => AppInfo.defaults(),
    error: (e, s) => AppInfo.defaults(),
  );
});
