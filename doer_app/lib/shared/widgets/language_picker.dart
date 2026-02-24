import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/translation/supported_languages.dart';
import '../../core/translation/translation_service.dart';
import '../../providers/translation_provider.dart';
import '../../core/translation/translation_extensions.dart';

/// Bottom sheet with a searchable list of all 59 ML Kit languages.
class LanguagePickerSheet extends ConsumerStatefulWidget {
  const LanguagePickerSheet({super.key});

  @override
  ConsumerState<LanguagePickerSheet> createState() =>
      _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends ConsumerState<LanguagePickerSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final Map<String, bool> _downloadedStatus = {};
  bool _loadingStatus = true;

  @override
  void initState() {
    super.initState();
    _loadDownloadStatus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDownloadStatus() async {
    for (final lang in kSupportedLanguages) {
      if (lang.code == 'en') {
        _downloadedStatus[lang.code] = true;
        continue;
      }
      final downloaded = await TranslationService.instance
          .isModelDownloaded(lang.mlKitLanguage);
      if (mounted) {
        setState(() {
          _downloadedStatus[lang.code] = downloaded;
        });
      }
    }
    if (mounted) {
      setState(() => _loadingStatus = false);
    }
  }

  List<SupportedLanguage> get _filteredLanguages {
    if (_searchQuery.isEmpty) return kSupportedLanguages;
    final query = _searchQuery.toLowerCase();
    return kSupportedLanguages.where((lang) {
      return lang.englishName.toLowerCase().contains(query) ||
          lang.nativeName.toLowerCase().contains(query) ||
          lang.code.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final translationState = ref.watch(translationProvider);
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Select Language'.tr(context),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search languages...'.tr(context),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _filteredLanguages.length,
                  itemBuilder: (context, index) {
                    final lang = _filteredLanguages[index];
                    final isSelected =
                        lang.code == translationState.selectedLanguageCode;
                    final isDownloaded = _downloadedStatus[lang.code] ?? false;
                    final isCurrentlyDownloading =
                        translationState.isDownloading &&
                            lang.code == translationState.selectedLanguageCode;

                    return ListTile(
                      leading: isSelected
                          ? Icon(Icons.check_circle,
                              color: theme.colorScheme.primary)
                          : const Icon(Icons.circle_outlined,
                              color: Colors.grey),
                      title: Text(
                        lang.nativeName,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        lang.englishName,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      trailing: _buildTrailingIcon(
                        lang,
                        isDownloaded,
                        isCurrentlyDownloading,
                        theme,
                      ),
                      onTap: () => _selectLanguage(lang),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrailingIcon(
    SupportedLanguage lang,
    bool isDownloaded,
    bool isCurrentlyDownloading,
    ThemeData theme,
  ) {
    if (lang.code == 'en') {
      return const SizedBox.shrink();
    }
    if (isCurrentlyDownloading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (isDownloaded) {
      return Icon(Icons.download_done, color: Colors.green[600], size: 20);
    }
    return Icon(Icons.download_outlined, color: Colors.grey[400], size: 20);
  }

  Future<void> _selectLanguage(SupportedLanguage lang) async {
    Navigator.pop(context);
    await ref.read(translationProvider.notifier).setLanguage(lang);
  }
}

/// Shows the language picker as a modal bottom sheet.
void showLanguagePicker(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const LanguagePickerSheet(),
  );
}
