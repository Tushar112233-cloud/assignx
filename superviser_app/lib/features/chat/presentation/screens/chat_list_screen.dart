import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../../../core/router/routes.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_room_tile.dart';

/// Screen displaying list of chat rooms.
///
/// Shows all active conversations grouped by project with hero section,
/// category filters, and mark-all-as-read functionality.
/// This is a TAB screen — transparent background, no gradient.
class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  String _selectedCategory = 'all';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filters chat rooms based on the selected category.
  List _filterRooms(List rooms) {
    switch (_selectedCategory) {
      case 'unread':
        return rooms.where((r) => r.hasUnread).toList();
      case 'client':
        return rooms
            .where((r) => r.type.value == 'client_supervisor')
            .toList();
      case 'expert':
        return rooms
            .where((r) => r.type.value == 'doer_supervisor')
            .toList();
      case 'group':
        return rooms.where((r) => r.type.value == 'group').toList();
      default:
        return rooms;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatRoomsProvider);
    final filteredRooms = _filterRooms(state.chatRooms);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Messages'.tr(context),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Mark all as read button
          if (state.totalUnread > 0)
            IconButton(
              onPressed: () {
                ref.read(chatRoomsProvider.notifier).refresh();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Marking all as read...'.tr(context)),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark All as Read'.tr(context),
            ),
          IconButton(
            onPressed: () => ref.read(chatRoomsProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(chatRoomsProvider.notifier).refresh(),
        child: state.isLoading && state.chatRooms.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.chatRooms.isEmpty
                ? const ChatListEmptyState()
                : _ChatListBody(
                    filteredRooms: filteredRooms,
                    state: state,
                    selectedCategory: _selectedCategory,
                    searchController: _searchController,
                    onCategorySelected: (category) {
                      setState(() => _selectedCategory = category);
                    },
                  ),
      ),
    );
  }
}

/// The scrollable body of the chat list, using [ListView.builder] for
/// lazy rendering of potentially large chat room lists.
class _ChatListBody extends StatelessWidget {
  const _ChatListBody({
    required this.filteredRooms,
    required this.state,
    required this.selectedCategory,
    required this.searchController,
    required this.onCategorySelected,
  });

  final List filteredRooms;
  final dynamic state;
  final String selectedCategory;
  final TextEditingController searchController;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    // Build the flat list of items: header widgets + filtered room tiles.
    final items = _buildItems(context);

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }

  /// Constructs the full list of widgets in display order:
  /// search bar, category chips, unread badge, section headers, and room tiles.
  List<Widget> _buildItems(BuildContext context) {
    final items = <Widget>[];

    // Top spacing
    items.add(const SizedBox(height: 8));

    // Glass search bar
    items.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GlassContainer(
          blur: 12,
          opacity: 0.6,
          borderRadius: BorderRadius.circular(14),
          borderColor: Colors.white.withAlpha(60),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: AppColors.textSecondaryLight,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search conversations...'.tr(context),
                    hintStyle: TextStyle(
                      color: AppColors.textTertiaryLight,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    items.add(const SizedBox(height: 12));

    // Category filter chips
    items.add(
      _CategoryChips(
        selected: selectedCategory,
        unreadCount: state.unreadRooms.length,
        onSelected: onCategorySelected,
      ),
    );

    items.add(const SizedBox(height: 8));

    // Unread count badge
    if (state.totalUnread > 0) {
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: GlassContainer(
            blur: 10,
            opacity: 0.15,
            borderRadius: BorderRadius.circular(12),
            borderColor: AppColors.accent.withAlpha(40),
            backgroundColor: AppColors.accent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.mark_email_unread_outlined, color: AppColors.accent, size: 18),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    '${state.totalUnread} ${'unread messages'.tr(context)}',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Filtered chat list items
    items.addAll(_buildFilteredList(context, filteredRooms));

    // Bottom padding for floating nav bar clearance
    items.add(const SizedBox(height: 100));

    return items;
  }

  /// Builds the filtered list of chat room tiles with section headers.
  List<Widget> _buildFilteredList(BuildContext context, List rooms) {
    if (rooms.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No chats in this category'.tr(context),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
          ),
        ),
      ];
    }

    final unreadRooms = rooms.where((r) => r.hasUnread).toList();
    final readRooms = rooms.where((r) => !r.hasUnread).toList();

    return [
      if (unreadRooms.isNotEmpty) ...[
        _SectionHeader(
          title: 'Unread'.tr(context),
          count: unreadRooms.length,
          color: AppColors.accent,
        ),
        ...unreadRooms.map((room) => ChatRoomTile(
              room: room,
              onTap: () =>
                  context.push('${RoutePaths.chat}/${room.projectId}'),
            )),
      ],
      if (readRooms.isNotEmpty) ...[
        _SectionHeader(
          title: unreadRooms.isNotEmpty ? 'Other Chats'.tr(context) : 'All Chats'.tr(context),
          count: readRooms.length,
        ),
        ...readRooms.map((room) => ChatRoomTile(
              room: room,
              onTap: () =>
                  context.push('${RoutePaths.chat}/${room.projectId}'),
            )),
      ],
    ];
  }
}

/// Horizontal scrolling category filter chips using glass style.
class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.selected,
    required this.unreadCount,
    required this.onSelected,
  });

  final String selected;
  final int unreadCount;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final categories = [
      ('all', 'All'.tr(context), Icons.chat_bubble_outline),
      ('unread', '${'Unread'.tr(context)} ($unreadCount)', Icons.mark_email_unread_outlined),
      ('client', 'Client'.tr(context), Icons.person_outline),
      ('expert', 'Expert'.tr(context), Icons.engineering_outlined),
      ('group', 'Group'.tr(context), Icons.group_outlined),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (value, label, icon) = categories[index];
          final isSelected = selected == value;

          return GestureDetector(
            onTap: () => onSelected(value),
            child: GlassContainer(
              blur: isSelected ? 15 : 8,
              opacity: isSelected ? 0.9 : 0.5,
              borderRadius: BorderRadius.circular(20),
              borderColor: isSelected
                  ? AppColors.accent.withAlpha(120)
                  : Colors.white.withAlpha(50),
              backgroundColor: isSelected ? AppColors.accent : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondaryLight,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Section header.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    this.color,
  });

  final String title;
  final int count;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Flexible(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color ?? AppColors.textSecondaryLight,
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (color ?? AppColors.textSecondaryLight)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color ?? AppColors.textSecondaryLight,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
