import 'package:flutter/foundation.dart';
import 'mlkit_stub.dart';

/// Singleton service managing ML Kit on-device translation.
///
/// All methods return English on web (`kIsWeb` guard).
class TranslationService {
  TranslationService._();
  static final instance = TranslationService._();

  OnDeviceTranslator? _translator;
  TranslateLanguage _currentTarget = TranslateLanguage.english;
  final _modelManager = OnDeviceTranslatorModelManager();

  /// Configures the translator for the given target language.
  void setTargetLanguage(TranslateLanguage target) {
    if (_currentTarget == target && _translator != null) return;
    _translator?.close();
    _currentTarget = target;
    _translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: target,
    );
  }

  /// Translates [text] from English to the current target language.
  ///
  /// Returns [text] unchanged on web or if target is English.
  Future<String> translate(String text) async {
    if (kIsWeb) return text;
    if (_currentTarget == TranslateLanguage.english) return text;
    if (_translator == null) return text;
    if (text.trim().isEmpty) return text;

    try {
      return await _translator!.translateText(text);
    } catch (e) {
      debugPrint('Translation error: $e');
      return text;
    }
  }

  /// Downloads the language model for on-device use (~30MB each).
  Future<bool> downloadModel(TranslateLanguage language) async {
    if (kIsWeb) return false;
    try {
      return await _modelManager.downloadModel(language.bcpCode);
    } catch (e) {
      debugPrint('Model download error: $e');
      return false;
    }
  }

  /// Checks if the model for [language] is already downloaded.
  Future<bool> isModelDownloaded(TranslateLanguage language) async {
    if (kIsWeb) return false;
    try {
      return await _modelManager.isModelDownloaded(language.bcpCode);
    } catch (e) {
      debugPrint('Model check error: $e');
      return false;
    }
  }

  /// Deletes a downloaded language model to free storage.
  Future<bool> deleteModel(TranslateLanguage language) async {
    if (kIsWeb) return false;
    try {
      return await _modelManager.deleteModel(language.bcpCode);
    } catch (e) {
      debugPrint('Model delete error: $e');
      return false;
    }
  }

  /// Closes the current translator and releases resources.
  void dispose() {
    _translator?.close();
    _translator = null;
  }
}
