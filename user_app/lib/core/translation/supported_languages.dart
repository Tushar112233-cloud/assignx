/// Represents a language supported for translation.
/// Stub version that doesn't depend on google_mlkit_translation.
class SupportedLanguage {
  final String mlKitLanguage; // Now just a string code instead of TranslateLanguage enum
  final String code;
  final String englishName;
  final String nativeName;

  const SupportedLanguage({
    required this.mlKitLanguage,
    required this.code,
    required this.englishName,
    required this.nativeName,
  });
}

/// All 59 languages (stub - mlKitLanguage is just the BCP code string).
const kSupportedLanguages = <SupportedLanguage>[
  SupportedLanguage(mlKitLanguage: 'af', code: 'af', englishName: 'Afrikaans', nativeName: 'Afrikaans'),
  SupportedLanguage(mlKitLanguage: 'sq', code: 'sq', englishName: 'Albanian', nativeName: 'Shqip'),
  SupportedLanguage(mlKitLanguage: 'ar', code: 'ar', englishName: 'Arabic', nativeName: 'العربية'),
  SupportedLanguage(mlKitLanguage: 'be', code: 'be', englishName: 'Belarusian', nativeName: 'Беларуская'),
  SupportedLanguage(mlKitLanguage: 'bn', code: 'bn', englishName: 'Bengali', nativeName: 'বাংলা'),
  SupportedLanguage(mlKitLanguage: 'bg', code: 'bg', englishName: 'Bulgarian', nativeName: 'Български'),
  SupportedLanguage(mlKitLanguage: 'ca', code: 'ca', englishName: 'Catalan', nativeName: 'Català'),
  SupportedLanguage(mlKitLanguage: 'zh', code: 'zh', englishName: 'Chinese', nativeName: '中文'),
  SupportedLanguage(mlKitLanguage: 'hr', code: 'hr', englishName: 'Croatian', nativeName: 'Hrvatski'),
  SupportedLanguage(mlKitLanguage: 'cs', code: 'cs', englishName: 'Czech', nativeName: 'Čeština'),
  SupportedLanguage(mlKitLanguage: 'da', code: 'da', englishName: 'Danish', nativeName: 'Dansk'),
  SupportedLanguage(mlKitLanguage: 'nl', code: 'nl', englishName: 'Dutch', nativeName: 'Nederlands'),
  SupportedLanguage(mlKitLanguage: 'en', code: 'en', englishName: 'English', nativeName: 'English'),
  SupportedLanguage(mlKitLanguage: 'eo', code: 'eo', englishName: 'Esperanto', nativeName: 'Esperanto'),
  SupportedLanguage(mlKitLanguage: 'et', code: 'et', englishName: 'Estonian', nativeName: 'Eesti'),
  SupportedLanguage(mlKitLanguage: 'fi', code: 'fi', englishName: 'Finnish', nativeName: 'Suomi'),
  SupportedLanguage(mlKitLanguage: 'fr', code: 'fr', englishName: 'French', nativeName: 'Français'),
  SupportedLanguage(mlKitLanguage: 'gl', code: 'gl', englishName: 'Galician', nativeName: 'Galego'),
  SupportedLanguage(mlKitLanguage: 'ka', code: 'ka', englishName: 'Georgian', nativeName: 'ქართული'),
  SupportedLanguage(mlKitLanguage: 'de', code: 'de', englishName: 'German', nativeName: 'Deutsch'),
  SupportedLanguage(mlKitLanguage: 'el', code: 'el', englishName: 'Greek', nativeName: 'Ελληνικά'),
  SupportedLanguage(mlKitLanguage: 'gu', code: 'gu', englishName: 'Gujarati', nativeName: 'ગુજરાતી'),
  SupportedLanguage(mlKitLanguage: 'ht', code: 'ht', englishName: 'Haitian Creole', nativeName: 'Kreyòl Ayisyen'),
  SupportedLanguage(mlKitLanguage: 'he', code: 'he', englishName: 'Hebrew', nativeName: 'עברית'),
  SupportedLanguage(mlKitLanguage: 'hi', code: 'hi', englishName: 'Hindi', nativeName: 'हिन्दी'),
  SupportedLanguage(mlKitLanguage: 'hu', code: 'hu', englishName: 'Hungarian', nativeName: 'Magyar'),
  SupportedLanguage(mlKitLanguage: 'is', code: 'is', englishName: 'Icelandic', nativeName: 'Íslenska'),
  SupportedLanguage(mlKitLanguage: 'id', code: 'id', englishName: 'Indonesian', nativeName: 'Bahasa Indonesia'),
  SupportedLanguage(mlKitLanguage: 'ga', code: 'ga', englishName: 'Irish', nativeName: 'Gaeilge'),
  SupportedLanguage(mlKitLanguage: 'it', code: 'it', englishName: 'Italian', nativeName: 'Italiano'),
  SupportedLanguage(mlKitLanguage: 'ja', code: 'ja', englishName: 'Japanese', nativeName: '日本語'),
  SupportedLanguage(mlKitLanguage: 'kn', code: 'kn', englishName: 'Kannada', nativeName: 'ಕನ್ನಡ'),
  SupportedLanguage(mlKitLanguage: 'ko', code: 'ko', englishName: 'Korean', nativeName: '한국어'),
  SupportedLanguage(mlKitLanguage: 'lv', code: 'lv', englishName: 'Latvian', nativeName: 'Latviešu'),
  SupportedLanguage(mlKitLanguage: 'lt', code: 'lt', englishName: 'Lithuanian', nativeName: 'Lietuvių'),
  SupportedLanguage(mlKitLanguage: 'mk', code: 'mk', englishName: 'Macedonian', nativeName: 'Македонски'),
  SupportedLanguage(mlKitLanguage: 'ms', code: 'ms', englishName: 'Malay', nativeName: 'Bahasa Melayu'),
  SupportedLanguage(mlKitLanguage: 'mt', code: 'mt', englishName: 'Maltese', nativeName: 'Malti'),
  SupportedLanguage(mlKitLanguage: 'mr', code: 'mr', englishName: 'Marathi', nativeName: 'मराठी'),
  SupportedLanguage(mlKitLanguage: 'no', code: 'no', englishName: 'Norwegian', nativeName: 'Norsk'),
  SupportedLanguage(mlKitLanguage: 'fa', code: 'fa', englishName: 'Persian', nativeName: 'فارسی'),
  SupportedLanguage(mlKitLanguage: 'pl', code: 'pl', englishName: 'Polish', nativeName: 'Polski'),
  SupportedLanguage(mlKitLanguage: 'pt', code: 'pt', englishName: 'Portuguese', nativeName: 'Português'),
  SupportedLanguage(mlKitLanguage: 'ro', code: 'ro', englishName: 'Romanian', nativeName: 'Română'),
  SupportedLanguage(mlKitLanguage: 'ru', code: 'ru', englishName: 'Russian', nativeName: 'Русский'),
  SupportedLanguage(mlKitLanguage: 'sk', code: 'sk', englishName: 'Slovak', nativeName: 'Slovenčina'),
  SupportedLanguage(mlKitLanguage: 'sl', code: 'sl', englishName: 'Slovenian', nativeName: 'Slovenščina'),
  SupportedLanguage(mlKitLanguage: 'es', code: 'es', englishName: 'Spanish', nativeName: 'Español'),
  SupportedLanguage(mlKitLanguage: 'sw', code: 'sw', englishName: 'Swahili', nativeName: 'Kiswahili'),
  SupportedLanguage(mlKitLanguage: 'sv', code: 'sv', englishName: 'Swedish', nativeName: 'Svenska'),
  SupportedLanguage(mlKitLanguage: 'tl', code: 'tl', englishName: 'Tagalog', nativeName: 'Tagalog'),
  SupportedLanguage(mlKitLanguage: 'ta', code: 'ta', englishName: 'Tamil', nativeName: 'தமிழ்'),
  SupportedLanguage(mlKitLanguage: 'te', code: 'te', englishName: 'Telugu', nativeName: 'తెలుగు'),
  SupportedLanguage(mlKitLanguage: 'th', code: 'th', englishName: 'Thai', nativeName: 'ไทย'),
  SupportedLanguage(mlKitLanguage: 'tr', code: 'tr', englishName: 'Turkish', nativeName: 'Türkçe'),
  SupportedLanguage(mlKitLanguage: 'uk', code: 'uk', englishName: 'Ukrainian', nativeName: 'Українська'),
  SupportedLanguage(mlKitLanguage: 'ur', code: 'ur', englishName: 'Urdu', nativeName: 'اردو'),
  SupportedLanguage(mlKitLanguage: 'vi', code: 'vi', englishName: 'Vietnamese', nativeName: 'Tiếng Việt'),
  SupportedLanguage(mlKitLanguage: 'cy', code: 'cy', englishName: 'Welsh', nativeName: 'Cymraeg'),
];
