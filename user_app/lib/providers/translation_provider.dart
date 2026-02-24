import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/translation/supported_languages.dart';
import '../core/translation/translation_cache.dart';
import '../core/translation/translation_service.dart';

/// State for the translation system.
class TranslationState {
  final String selectedLanguageCode;
  final String selectedLanguageName;
  final bool isModelDownloaded;
  final bool isDownloading;

  /// Incremented each time a new translation becomes available,
  /// causing widgets using `.tr(context)` to rebuild.
  final int translationVersion;

  const TranslationState({
    this.selectedLanguageCode = 'en',
    this.selectedLanguageName = 'English',
    this.isModelDownloaded = true,
    this.isDownloading = false,
    this.translationVersion = 0,
  });

  TranslationState copyWith({
    String? selectedLanguageCode,
    String? selectedLanguageName,
    bool? isModelDownloaded,
    bool? isDownloading,
    int? translationVersion,
  }) {
    return TranslationState(
      selectedLanguageCode: selectedLanguageCode ?? this.selectedLanguageCode,
      selectedLanguageName: selectedLanguageName ?? this.selectedLanguageName,
      isModelDownloaded: isModelDownloaded ?? this.isModelDownloaded,
      isDownloading: isDownloading ?? this.isDownloading,
      translationVersion: translationVersion ?? this.translationVersion,
    );
  }
}

/// Storage keys for language preferences.
const String _langCodeKey = 'selected_language_code';
const String _langNameKey = 'selected_language_name';

/// Manages translation state: language selection, model downloads, and caching.
///
/// Follows the same `StateNotifier` + `SharedPreferences` pattern as `ThemeNotifier`.
class TranslationNotifier extends StateNotifier<TranslationState> {
  TranslationNotifier() : super(const TranslationState()) {
    _loadSavedLanguage();
  }

  /// Loads the previously saved language from SharedPreferences.
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_langCodeKey) ?? 'en';
      final name = prefs.getString(_langNameKey) ?? 'English';

      if (code != 'en') {
        // Find the language and configure the translator
        final lang = kSupportedLanguages.firstWhere(
          (l) => l.code == code,
          orElse: () => kSupportedLanguages.firstWhere((l) => l.code == 'en'),
        );

        TranslationService.instance.setTargetLanguage(lang.mlKitLanguage);
        await TranslationCache.instance.load(code);

        final downloaded = await TranslationService.instance
            .isModelDownloaded(lang.mlKitLanguage);

        state = state.copyWith(
          selectedLanguageCode: code,
          selectedLanguageName: name,
          isModelDownloaded: downloaded,
        );
      }
    } catch (e) {
      debugPrint('Failed to load language preference: $e');
    }
  }

  /// Sets the app language. Downloads model if needed.
  Future<void> setLanguage(SupportedLanguage language) async {
    if (language.code == state.selectedLanguageCode) return;

    // Save preference
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_langCodeKey, language.code);
      await prefs.setString(_langNameKey, language.englishName);
    } catch (e) {
      debugPrint('Failed to save language preference: $e');
    }

    if (language.code == 'en') {
      state = const TranslationState();
      return;
    }

    // Configure translator
    TranslationService.instance.setTargetLanguage(language.mlKitLanguage);

    // Check if model is downloaded
    final downloaded = await TranslationService.instance
        .isModelDownloaded(language.mlKitLanguage);

    state = state.copyWith(
      selectedLanguageCode: language.code,
      selectedLanguageName: language.englishName,
      isModelDownloaded: downloaded,
      isDownloading: !downloaded,
    );

    // Download model if needed
    if (!downloaded) {
      final success = await TranslationService.instance
          .downloadModel(language.mlKitLanguage);
      state = state.copyWith(
        isModelDownloaded: success,
        isDownloading: false,
      );
    }

    // Load cached translations
    await TranslationCache.instance.load(language.code);

    // Trigger rebuild so .tr() picks up the new language
    state = state.copyWith(
      translationVersion: state.translationVersion + 1,
    );
  }

  /// Resets the app back to English.
  Future<void> resetToEnglish() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_langCodeKey, 'en');
      await prefs.setString(_langNameKey, 'English');
    } catch (e) {
      debugPrint('Failed to save language preference: $e');
    }
    state = const TranslationState();
  }

  /// Called by `.tr()` extension when a new translation is cached.
  /// Increments version to trigger widget rebuilds.
  void notifyTranslationReady() {
    state = state.copyWith(
      translationVersion: state.translationVersion + 1,
    );
    // Periodically save cache to disk
    TranslationCache.instance.save(state.selectedLanguageCode);
  }
}

/// Global provider for the translation system.
final translationProvider =
    StateNotifierProvider<TranslationNotifier, TranslationState>((ref) {
  return TranslationNotifier();
});
