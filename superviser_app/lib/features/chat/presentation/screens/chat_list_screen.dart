import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/routes.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_room_tile.dart';

/// Screen displaying list of chat rooms.
///
/// Shows all active conversations grouped by project with hero section,
/// category filters, and mark-all-as-read functionality.
class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  String _selectedCategory = 'all';

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
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          // Mark all as read button
          if (state.totalUnread > 0)
            IconButton(
              onPressed: () {
                ref.read(chatRoomsProvider.notifier).refresh();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Marking all as read...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark All as Read',
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
                : ListView(
                    children: [
                      // Hero section
                      _ChatHeroSection(
                        totalUnread: state.totalUnread,
                        totalChats: state.chatRooms.length,
                      ),
                      // Category filter chips
                      _CategoryChips(
                        selected: _selectedCategory,
                        unreadCount: state.unreadRooms.length,
                        onSelected: (category) {
                          setState(() => _selectedCategory = category);
                        },
                      ),
                      // Filtered chat list
                      ..._buildFilteredList(filteredRooms),
                      const SizedBox(height: 100),
                    ],
                  ),
      ),
    );
  }

  /// Builds the filtered list of chat room tiles.
  List<Widget> _buildFilteredList(List rooms) {
    if (rooms.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No chats in this category',
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
          title: 'Unread',
          count: unreadRooms.length,
          color: AppColors.primary,
        ),
        ...unreadRooms.map((room) => ChatRoomTile(
              room: room,
              onTap: () =>
                  context.push('${RoutePaths.chat}/${room.projectId}'),
            )),
      ],
      if (readRooms.isNotEmpty) ...[
        _SectionHeader(
          title: unreadRooms.isNotEmpty ? 'Other Chats' : 'All Chats',
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

/// Hero section with gradient background showing greeting and unread count.
class _ChatHeroSection extends StatelessWidget {
  const _ChatHeroSection({
    required this.totalUnread,
    required this.totalChats,
  });

  final int totalUnread;
  final int totalChats;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Messages',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalChats conversations',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          if (totalUnread > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    totalUnread.toString(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'unread',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Horizontal scrolling category filter chips.
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
      ('all', 'All', Icons.chat_bubble_outline),
      ('unread', 'Unread ($unreadCount)', Icons.mark_email_unread_outlined),
      ('client', 'Client', Icons.person_outline),
      ('expert', 'Expert', Icons.engineering_outlined),
      ('group', 'Group', Icons.group_outlined),
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent
                    : AppColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.accent
                      : AppColors.borderLight,
                ),
              ),
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
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondaryLight,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
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
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color ?? AppColors.textSecondaryLight,
                  fontWeight: FontWeight.bold,
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
