import 'package:flutter/foundation.dart';

/// Stub translation service for simulator testing.
/// The real implementation uses google_mlkit_translation which doesn't
/// have arm64 simulator slices. This stub returns text unchanged.
class TranslationService {
  TranslationService._();
  static final instance = TranslationService._();

  String _currentTarget = 'en';

  /// Configures the translator for the given target language.
  void setTargetLanguage(String target) {
    _currentTarget = target;
  }

  /// Returns [text] unchanged (stub - no ML Kit on simulator).
  Future<String> translate(String text) async {
    return text;
  }

  /// Stub - always returns false.
  Future<bool> downloadModel(String languageCode) async {
    debugPrint('TranslationService stub: downloadModel($languageCode)');
    return false;
  }

  /// Stub - always returns false.
  Future<bool> isModelDownloaded(String languageCode) async {
    return false;
  }

  /// Stub - always returns false.
  Future<bool> deleteModel(String languageCode) async {
    return false;
  }

  /// No-op.
  void dispose() {}
}
