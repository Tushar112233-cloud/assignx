import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'translation_provider.dart';
import 'translation_cache.dart';
import 'translation_service.dart';

/// Extension on [String] providing `.tr(context)` for on-the-fly translation.
///
/// On web: returns `this` immediately (ML Kit is mobile-only).
/// If language is English: returns `this`.
/// Checks in-memory cache first (sync, instant).
/// On cache miss: returns English, triggers async translation → provider
/// notifies widgets to rebuild when translation is ready.
extension TranslateString on String {
  String tr(BuildContext context) {
    // On web, always return English
    if (kIsWeb) return this;

    // Empty strings pass through
    if (trim().isEmpty) return this;

    try {
      final container = ProviderScope.containerOf(context, listen: false);
      final state = container.read(translationProvider);

      // If English is selected, return as-is
      if (state.selectedLanguageCode == 'en') return this;

      // Check in-memory cache (synchronous, instant)
      final cached = TranslationCache.instance.get(
        state.selectedLanguageCode,
        this,
      );
      if (cached != null) return cached;

      // Cache miss: trigger async translation, return English for now
      _translateAsync(state.selectedLanguageCode, container);

      return this;
    } catch (_) {
      // If providers aren't available yet, return English
      return this;
    }
  }

  void _translateAsync(String langCode, ProviderContainer container) async {
    try {
      final translated = await TranslationService.instance.translate(this);
      if (translated != this) {
        TranslationCache.instance.put(langCode, this, translated);
        // Notify the provider to trigger widget rebuilds
        container.read(translationProvider.notifier).notifyTranslationReady();
      }
    } catch (_) {
      // Silently fail — English is already shown
    }
  }
}
