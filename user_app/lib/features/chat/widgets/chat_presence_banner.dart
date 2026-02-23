import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Type of presence event.
enum PresenceEventType {
  joined,
  left,
}

/// Represents a chat presence event (user joining/leaving).
/// Named ChatPresenceEvent to avoid conflict with Supabase's PresenceEvent.
class ChatPresenceEvent {
  final String id;
  final PresenceEventType type;
  final String userName;
  final String? userRole;
  final String? avatarUrl;
  final int timestamp;

  const ChatPresenceEvent({
    required this.id,
    required this.type,
    required this.userName,
    this.userRole,
    this.avatarUrl,
    required this.timestamp,
  });

  /// Creates a unique ID for a new event.
  static String generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecond}';
  }
}

/// Alias for backward compatibility
typedef PresenceEvent = ChatPresenceEvent;

/// Slide-in banner for presence updates with auto-dismiss.
///
/// Shows notifications when users join or leave the chat.
/// Automatically dismisses after 3 seconds with smooth animations.
///
/// Example:
/// ```dart
/// ChatPresenceBanner(
///   event: PresenceEvent(
///     id: 'unique-id',
///     type: PresenceEventType.joined,
///     userName: 'Supervisor',
///     userRole: 'Expert',
///     timestamp: DateTime.now().millisecondsSinceEpoch,
///   ),
///   onDismiss: () => removeEvent(event.id),
/// )
/// ```
class ChatPresenceBanner extends StatefulWidget {
  /// The presence event to display.
  final PresenceEvent event;

  /// Callback when the banner should be dismissed.
  final VoidCallback? onDismiss;

  /// Duration before auto-dismiss. Defaults to 3 seconds.
  final Duration autoDismissDuration;

  const ChatPresenceBanner({
    super.key,
    required this.event,
    this.onDismiss,
    this.autoDismissDuration = const Duration(seconds: 3),
  });

  @override
  State<ChatPresenceBanner> createState() => _ChatPresenceBannerState();
}

class _ChatPresenceBannerState extends State<ChatPresenceBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Start entrance animation
    _controller.forward();

    // Schedule auto-dismiss
    _dismissTimer = Timer(widget.autoDismissDuration, _dismiss);
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isJoin = widget.event.type == PresenceEventType.joined;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isJoin
                        ? [
                            AppColors.primary.withValues(alpha: 0.2),
                            AppColors.accent.withValues(alpha: 0.1),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.1),
                            Colors.white.withValues(alpha: 0.05),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isJoin
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar
                    _buildAvatar(isJoin),

                    const SizedBox(width: 8),

                    // Icon
                    Icon(
                      isJoin ? Icons.person_add_rounded : Icons.person_remove_rounded,
                      size: 16,
                      color: isJoin
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.7),
                    ),

                    const SizedBox(width: 8),

                    // Message
                    Flexible(
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          children: [
                            TextSpan(
                              text: widget.event.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            if (widget.event.userRole != null) ...[
                              TextSpan(
                                text: ' (${widget.event.userRole})',
                                style: TextStyle(
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                            TextSpan(
                              text: isJoin
                                  ? ' joined the chat'
                                  : ' left the chat',
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isJoin) {
    final initial = widget.event.userName.isNotEmpty
        ? widget.event.userName[0].toUpperCase()
        : '?';

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isJoin
              ? [AppColors.primary, AppColors.accent]
              : [Colors.white.withValues(alpha: 0.3), Colors.white.withValues(alpha: 0.1)],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: AppTextStyles.labelSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

/// Widget that manages and displays multiple presence banners.
///
/// Handles the lifecycle of presence events, including auto-dismissal
/// and stacking of multiple notifications.
class ChatPresenceStack extends StatefulWidget {
  /// Stream of presence events to display.
  final Stream<PresenceEvent> eventStream;

  /// Maximum number of banners to show at once.
  final int maxBanners;

  const ChatPresenceStack({
    super.key,
    required this.eventStream,
    this.maxBanners = 3,
  });

  @override
  State<ChatPresenceStack> createState() => _ChatPresenceStackState();
}

class _ChatPresenceStackState extends State<ChatPresenceStack> {
  final List<PresenceEvent> _events = [];
  StreamSubscription<PresenceEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.eventStream.listen(_addEvent);
  }

  void _addEvent(PresenceEvent event) {
    setState(() {
      _events.add(event);
      // Keep only the most recent events
      if (_events.length > widget.maxBanners) {
        _events.removeAt(0);
      }
    });
  }

  void _removeEvent(String eventId) {
    setState(() {
      _events.removeWhere((e) => e.id == eventId);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _events.map((event) {
        return ChatPresenceBanner(
          key: ValueKey(event.id),
          event: event,
          onDismiss: () => _removeEvent(event.id),
        );
      }).toList(),
    );
  }
}

/// Online users indicator showing who's currently in the chat.
///
/// Displays a row of stacked avatars with an online count.
class OnlineUsersIndicator extends StatelessWidget {
  /// List of online users.
  final List<OnlineUser> users;

  /// Maximum number of avatars to display.
  final int maxAvatars;

  const OnlineUsersIndicator({
    super.key,
    required this.users,
    this.maxAvatars = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const SizedBox.shrink();

    final displayUsers = users.take(maxAvatars).toList();
    final remainingCount = users.length - displayUsers.length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsing online dot
              _PulsingDot(),

              const SizedBox(width: 8),

              // Stacked avatars
              SizedBox(
                height: 20,
                child: Stack(
                  children: [
                    ...displayUsers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final user = entry.value;
                      return Positioned(
                        left: index * 14.0,
                        child: _MiniAvatar(
                          name: user.name,
                          avatarUrl: user.avatarUrl,
                        ),
                      );
                    }),
                    if (remainingCount > 0)
                      Positioned(
                        left: displayUsers.length * 14.0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '+$remainingCount',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(
                width: 8 + (displayUsers.length - 1) * 14.0 + (remainingCount > 0 ? 14 : 0),
              ),

              // Label
              Text(
                users.length == 1 ? '1 online' : '${users.length} online',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small avatar for the online users indicator.
class _MiniAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;

  const _MiniAvatar({
    required this.name,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF16213E),
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: avatarUrl != null
            ? Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildInitial(initial),
              )
            : _buildInitial(initial),
      ),
    );
  }

  Widget _buildInitial(String initial) {
    return Center(
      child: Text(
        initial,
        style: AppTextStyles.labelSmall.copyWith(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Pulsing green dot to indicate online status.
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10,
      height: 10,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing ring
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: 10 * _animation.value,
                height: 10 * _animation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withValues(alpha: 0.3 * (1 - _animation.value)),
                ),
              );
            },
          ),
          // Solid dot
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Represents an online user in the chat.
class OnlineUser {
  final String id;
  final String name;
  final String? role;
  final String? avatarUrl;

  const OnlineUser({
    required this.id,
    required this.name,
    this.role,
    this.avatarUrl,
  });

  factory OnlineUser.fromJson(Map<String, dynamic> json) {
    return OnlineUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      role: json['role'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
