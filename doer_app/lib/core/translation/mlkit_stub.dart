/// Stub types for google_mlkit_translation when the package is disabled.
/// Provides the same API surface so the rest of the code compiles unchanged.

enum TranslateLanguage {
  afrikaans, albanian, arabic, belarusian, bengali, bulgarian, catalan,
  chinese, croatian, czech, danish, dutch, english, esperanto, estonian,
  finnish, french, galician, georgian, german, greek, gujarati, haitian,
  hebrew, hindi, hungarian, icelandic, indonesian, irish, italian,
  japanese, kannada, korean, latvian, lithuanian, macedonian, malay,
  maltese, marathi, norwegian, persian, polish, portuguese, romanian,
  russian, slovak, slovenian, spanish, swahili, swedish, tagalog,
  tamil, telugu, thai, turkish, ukrainian, urdu, vietnamese, welsh;

  String get bcpCode => name;
}

class OnDeviceTranslator {
  final TranslateLanguage sourceLanguage;
  final TranslateLanguage targetLanguage;

  OnDeviceTranslator({
    required this.sourceLanguage,
    required this.targetLanguage,
  });

  Future<String> translateText(String text) async => text;
  void close() {}
}

class OnDeviceTranslatorModelManager {
  Future<bool> downloadModel(String langCode) async => false;
  Future<bool> isModelDownloaded(String langCode) async => false;
  Future<bool> deleteModel(String langCode) async => false;
}
