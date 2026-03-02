import 'mlkit_stub.dart';

/// Represents a language supported by ML Kit on-device translation.
class SupportedLanguage {
  final TranslateLanguage mlKitLanguage;
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

/// All 59 languages supported by Google ML Kit Translation.
const kSupportedLanguages = <SupportedLanguage>[
  SupportedLanguage(mlKitLanguage: TranslateLanguage.afrikaans, code: 'af', englishName: 'Afrikaans', nativeName: 'Afrikaans'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.albanian, code: 'sq', englishName: 'Albanian', nativeName: 'Shqip'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.arabic, code: 'ar', englishName: 'Arabic', nativeName: 'العربية'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.belarusian, code: 'be', englishName: 'Belarusian', nativeName: 'Беларуская'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.bengali, code: 'bn', englishName: 'Bengali', nativeName: 'বাংলা'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.bulgarian, code: 'bg', englishName: 'Bulgarian', nativeName: 'Български'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.catalan, code: 'ca', englishName: 'Catalan', nativeName: 'Català'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.chinese, code: 'zh', englishName: 'Chinese', nativeName: '中文'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.croatian, code: 'hr', englishName: 'Croatian', nativeName: 'Hrvatski'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.czech, code: 'cs', englishName: 'Czech', nativeName: 'Čeština'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.danish, code: 'da', englishName: 'Danish', nativeName: 'Dansk'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.dutch, code: 'nl', englishName: 'Dutch', nativeName: 'Nederlands'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.english, code: 'en', englishName: 'English', nativeName: 'English'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.esperanto, code: 'eo', englishName: 'Esperanto', nativeName: 'Esperanto'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.estonian, code: 'et', englishName: 'Estonian', nativeName: 'Eesti'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.finnish, code: 'fi', englishName: 'Finnish', nativeName: 'Suomi'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.french, code: 'fr', englishName: 'French', nativeName: 'Français'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.galician, code: 'gl', englishName: 'Galician', nativeName: 'Galego'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.georgian, code: 'ka', englishName: 'Georgian', nativeName: 'ქართული'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.german, code: 'de', englishName: 'German', nativeName: 'Deutsch'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.greek, code: 'el', englishName: 'Greek', nativeName: 'Ελληνικά'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.gujarati, code: 'gu', englishName: 'Gujarati', nativeName: 'ગુજરાતી'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.haitian, code: 'ht', englishName: 'Haitian Creole', nativeName: 'Kreyòl Ayisyen'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.hebrew, code: 'he', englishName: 'Hebrew', nativeName: 'עברית'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.hindi, code: 'hi', englishName: 'Hindi', nativeName: 'हिन्दी'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.hungarian, code: 'hu', englishName: 'Hungarian', nativeName: 'Magyar'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.icelandic, code: 'is', englishName: 'Icelandic', nativeName: 'Íslenska'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.indonesian, code: 'id', englishName: 'Indonesian', nativeName: 'Bahasa Indonesia'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.irish, code: 'ga', englishName: 'Irish', nativeName: 'Gaeilge'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.italian, code: 'it', englishName: 'Italian', nativeName: 'Italiano'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.japanese, code: 'ja', englishName: 'Japanese', nativeName: '日本語'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.kannada, code: 'kn', englishName: 'Kannada', nativeName: 'ಕನ್ನಡ'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.korean, code: 'ko', englishName: 'Korean', nativeName: '한국어'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.latvian, code: 'lv', englishName: 'Latvian', nativeName: 'Latviešu'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.lithuanian, code: 'lt', englishName: 'Lithuanian', nativeName: 'Lietuvių'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.macedonian, code: 'mk', englishName: 'Macedonian', nativeName: 'Македонски'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.malay, code: 'ms', englishName: 'Malay', nativeName: 'Bahasa Melayu'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.maltese, code: 'mt', englishName: 'Maltese', nativeName: 'Malti'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.marathi, code: 'mr', englishName: 'Marathi', nativeName: 'मराठी'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.norwegian, code: 'no', englishName: 'Norwegian', nativeName: 'Norsk'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.persian, code: 'fa', englishName: 'Persian', nativeName: 'فارسی'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.polish, code: 'pl', englishName: 'Polish', nativeName: 'Polski'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.portuguese, code: 'pt', englishName: 'Portuguese', nativeName: 'Português'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.romanian, code: 'ro', englishName: 'Romanian', nativeName: 'Română'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.russian, code: 'ru', englishName: 'Russian', nativeName: 'Русский'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.slovak, code: 'sk', englishName: 'Slovak', nativeName: 'Slovenčina'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.slovenian, code: 'sl', englishName: 'Slovenian', nativeName: 'Slovenščina'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.spanish, code: 'es', englishName: 'Spanish', nativeName: 'Español'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.swahili, code: 'sw', englishName: 'Swahili', nativeName: 'Kiswahili'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.swedish, code: 'sv', englishName: 'Swedish', nativeName: 'Svenska'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.tagalog, code: 'tl', englishName: 'Tagalog', nativeName: 'Tagalog'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.tamil, code: 'ta', englishName: 'Tamil', nativeName: 'தமிழ்'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.telugu, code: 'te', englishName: 'Telugu', nativeName: 'తెలుగు'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.thai, code: 'th', englishName: 'Thai', nativeName: 'ไทย'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.turkish, code: 'tr', englishName: 'Turkish', nativeName: 'Türkçe'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.ukrainian, code: 'uk', englishName: 'Ukrainian', nativeName: 'Українська'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.urdu, code: 'ur', englishName: 'Urdu', nativeName: 'اردو'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.vietnamese, code: 'vi', englishName: 'Vietnamese', nativeName: 'Tiếng Việt'),
  SupportedLanguage(mlKitLanguage: TranslateLanguage.welsh, code: 'cy', englishName: 'Welsh', nativeName: 'Cymraeg'),
];
