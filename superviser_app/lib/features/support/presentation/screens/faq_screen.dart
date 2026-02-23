import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/services/external_actions_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/support_provider.dart';
import '../widgets/faq_accordion.dart';

/// FAQ screen.
class FAQScreen extends ConsumerStatefulWidget {
  const FAQScreen({super.key});

  @override
  ConsumerState<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends ConsumerState<FAQScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(faqProvider.notifier).loadFAQ();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(faqProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search FAQ...',
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  ref.read(faqProvider.notifier).search(query);
                },
              )
            : const Text('FAQ'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref.read(faqProvider.notifier).clearSearch();
                }
              });
            },
            icon: Icon(_isSearching ? Icons.close : Icons.search),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.searchQuery.isNotEmpty
              ? _SearchResults(
                  results: state.searchResults,
                  query: state.searchQuery,
                  isSearching: state.isSearching,
                )
              : _FAQContent(
                  items: state.items,
                  categories: state.categories,
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(RouteNames.support),
        icon: const Icon(Icons.support_agent),
        label: const Text('Contact Support'),
      ),
    );
  }
}

/// FAQ content with categories or flat list.
class _FAQContent extends ConsumerWidget {
  const _FAQContent({
    required this.items,
    required this.categories,
  });

  final List items;
  final List categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty && categories.isEmpty) {
      return const EmptyFAQ();
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Frequently Asked Questions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Find answers to common questions',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
              ),
            ],
          ),
        ),

        // FAQ items
        if (items.isNotEmpty) ...[
          FAQAccordion(
            items: items.cast(),
            onToggle: (itemId) {
              ref.read(faqProvider.notifier).toggleItem(itemId);
            },
          ),
        ],

        // Quick links
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Need more help?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 12),
        _QuickLinksSection(),
      ],
    );
  }
}

/// Search results view.
class _SearchResults extends ConsumerWidget {
  const _SearchResults({
    required this.results,
    required this.query,
    required this.isSearching,
  });

  final List results;
  final String query;
  final bool isSearching;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    return FAQSearchResults(
      results: results.cast(),
      query: query,
      onItemTap: (item) {
        // Show answer in dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(item.question),
            content: SingleChildScrollView(
              child: Text(item.answer),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Quick links section.
class _QuickLinksSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final externalActions = ref.read(externalActionsServiceProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _QuickLinkCard(
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'support@adminx.com',
            onTap: () {
              externalActions.sendEmail(
                to: 'support@adminx.com',
                subject: 'Support Request',
              );
            },
          ),
          const SizedBox(height: 8),
          _QuickLinkCard(
            icon: Icons.chat_outlined,
            title: 'Live Chat',
            subtitle: 'Available 9 AM - 6 PM',
            onTap: () {
              externalActions.openLiveChat();
            },
          ),
          const SizedBox(height: 8),
          _QuickLinkCard(
            icon: Icons.phone_outlined,
            title: 'Phone Support',
            subtitle: '+1 (555) 123-4567',
            onTap: () {
              externalActions.makePhoneCall('+15551234567');
            },
          ),
        ],
      ),
    );
  }
}

class _QuickLinkCard extends StatelessWidget {
  const _QuickLinkCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
