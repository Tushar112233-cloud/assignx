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

const String _langCodeKey = 'selected_language_code';
const String _langNameKey = 'selected_language_name';

/// Manages translation state: language selection, model downloads, and caching.
class TranslationNotifier extends StateNotifier<TranslationState> {
  TranslationNotifier() : super(const TranslationState()) {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_langCodeKey) ?? 'en';
      final name = prefs.getString(_langNameKey) ?? 'English';

      if (code != 'en') {
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

  Future<void> setLanguage(SupportedLanguage language) async {
    if (language.code == state.selectedLanguageCode) return;

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

    TranslationService.instance.setTargetLanguage(language.mlKitLanguage);

    final downloaded = await TranslationService.instance
        .isModelDownloaded(language.mlKitLanguage);

    state = state.copyWith(
      selectedLanguageCode: language.code,
      selectedLanguageName: language.englishName,
      isModelDownloaded: downloaded,
      isDownloading: !downloaded,
    );

    if (!downloaded) {
      final success = await TranslationService.instance
          .downloadModel(language.mlKitLanguage);
      state = state.copyWith(
        isModelDownloaded: success,
        isDownloading: false,
      );
    }

    await TranslationCache.instance.load(language.code);

    state = state.copyWith(
      translationVersion: state.translationVersion + 1,
    );
  }

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

  void notifyTranslationReady() {
    state = state.copyWith(
      translationVersion: state.translationVersion + 1,
    );
    TranslationCache.instance.save(state.selectedLanguageCode);
  }
}

final translationProvider =
    StateNotifierProvider<TranslationNotifier, TranslationState>((ref) {
  return TranslationNotifier();
});
