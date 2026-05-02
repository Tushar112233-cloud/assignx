import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

/// Supported language option with display metadata.
class LanguageOption {
  /// Language display name.
  final String name;

  /// Flag emoji for the language.
  final String flag;

  /// Locale code (e.g., 'en', 'hi', 'fr').
  final String code;

  /// Whether the language uses right-to-left text direction.
  final bool isRtl;

  const LanguageOption({
    required this.name,
    required this.flag,
    required this.code,
    this.isRtl = false,
  });
}

/// Available language options matching the web application.
const kLanguageOptions = [
  LanguageOption(name: 'English', flag: '\u{1F1FA}\u{1F1F8}', code: 'en'),
  LanguageOption(name: 'Hindi', flag: '\u{1F1EE}\u{1F1F3}', code: 'hi'),
  LanguageOption(name: 'Francais', flag: '\u{1F1EB}\u{1F1F7}', code: 'fr'),
  LanguageOption(
    name: 'Arabic',
    flag: '\u{1F1E6}\u{1F1EA}',
    code: 'ar',
    isRtl: true,
  ),
  LanguageOption(name: 'Espanol', flag: '\u{1F1EA}\u{1F1F8}', code: 'es'),
  LanguageOption(name: 'Chinese', flag: '\u{1F1E8}\u{1F1F3}', code: 'zh'),
];

/// SharedPreferences key for persisted language choice.
const String _languageStorageKey = 'app_language';

/// Riverpod provider for the selected language code.
///
/// Reads from SharedPreferences on initialization and
/// persists changes when updated.
final languageProvider =
    StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});

/// State notifier for managing the selected language preference.
class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('en') {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_languageStorageKey);
      if (stored != null) {
        state = stored;
      }
    } catch (_) {
      // Keep default
    }
  }

  /// Sets the selected language and persists to SharedPreferences.
  Future<void> setLanguage(String code) async {
    if (state == code) return;
    state = code;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageStorageKey, code);
    } catch (_) {
      // Silent fail - preference will be lost on restart
    }
  }
}

/// Bottom sheet displaying available languages for selection.
///
/// Shows 6 language options with flag emojis. The currently selected
/// language is indicated by a checkmark. Selection saves to
/// SharedPreferences and updates the locale via Riverpod.
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  /// Shows the language selector as a modal bottom sheet.
  static void show(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: false,
      context: context,
      useRootNavigator: true,

      backgroundColor: Colors.transparent,
      builder: (_) => const LanguageSelector(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCode = ref.watch(languageProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                const Icon(
                  Icons.language,
                  size: 22,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Select Language',
                  style: AppTextStyles.headingSmall,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Language options
          ...kLanguageOptions.map((lang) {
            final isSelected = selectedCode == lang.code;
            return ListTile(
              leading: Text(
                lang.flag,
                style: const TextStyle(fontSize: 28),
              ),
              title: Text(
                lang.name,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
              subtitle: lang.isRtl
                  ? Text(
                      'RTL',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    )
                  : null,
              trailing: isSelected
                  ? const Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 22,
                    )
                  : null,
              onTap: () {
                ref.read(languageProvider.notifier).setLanguage(lang.code);
                Navigator.of(context).pop();
              },
            );
          }),

          SizedBox(
            height: MediaQuery.of(context).padding.bottom + AppSpacing.md,
          ),
        ],
      ),
    );
  }
}
