import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists translations in SharedPreferences as JSON.
///
/// Capped at [maxEntries] per language with LRU eviction.
class TranslationCache {
  TranslationCache._();
  static final instance = TranslationCache._();

  static const int maxEntries = 2000;
  static const String _prefix = 'translation_cache_';

  /// In-memory cache: langCode → { english → translated }.
  final Map<String, Map<String, String>> _memoryCache = {};

  /// LRU order tracking: langCode → list of keys (most recent last).
  final Map<String, List<String>> _lruOrder = {};

  /// Loads cached translations for [langCode] from SharedPreferences.
  Future<Map<String, String>> load(String langCode) async {
    if (_memoryCache.containsKey(langCode)) {
      return _memoryCache[langCode]!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('$_prefix$langCode');
      if (jsonStr != null) {
        final decoded = json.decode(jsonStr) as Map<String, dynamic>;
        final translations = decoded.map((k, v) => MapEntry(k, v as String));
        _memoryCache[langCode] = translations;
        _lruOrder[langCode] = translations.keys.toList();
        return translations;
      }
    } catch (e) {
      debugPrint('TranslationCache load error: $e');
    }

    _memoryCache[langCode] = {};
    _lruOrder[langCode] = [];
    return {};
  }

  /// Gets a cached translation from memory (synchronous).
  String? get(String langCode, String englishText) {
    final cached = _memoryCache[langCode];
    if (cached == null) return null;
    final result = cached[englishText];
    if (result != null) {
      // Update LRU order
      final order = _lruOrder[langCode];
      if (order != null) {
        order.remove(englishText);
        order.add(englishText);
      }
    }
    return result;
  }

  /// Adds a translation to the in-memory cache.
  void put(String langCode, String englishText, String translatedText) {
    _memoryCache.putIfAbsent(langCode, () => {});
    _lruOrder.putIfAbsent(langCode, () => []);

    final cache = _memoryCache[langCode]!;
    final order = _lruOrder[langCode]!;

    // Remove from LRU if already exists
    order.remove(englishText);
    order.add(englishText);
    cache[englishText] = translatedText;

    // Evict oldest entries if over limit
    while (cache.length > maxEntries) {
      final oldest = order.removeAt(0);
      cache.remove(oldest);
    }
  }

  /// Persists the current in-memory cache for [langCode] to disk.
  Future<void> save(String langCode) async {
    final cache = _memoryCache[langCode];
    if (cache == null || cache.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefix$langCode', json.encode(cache));
    } catch (e) {
      debugPrint('TranslationCache save error: $e');
    }
  }

  /// Clears all cached translations for [langCode].
  Future<void> clear(String langCode) async {
    _memoryCache.remove(langCode);
    _lruOrder.remove(langCode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_prefix$langCode');
    } catch (e) {
      debugPrint('TranslationCache clear error: $e');
    }
  }
}
