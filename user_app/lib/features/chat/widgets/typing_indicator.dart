import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Animated 3-dot typing indicator widget.
///
/// Displays a subtle animation showing that someone is typing in the chat.
/// Uses glass morphism styling to match the app's design system.
///
/// Example:
/// ```dart
/// TypingIndicator(
///   typerName: 'Supervisor',
///   isVisible: isSupervisorTyping,
/// )
/// ```
class TypingIndicator extends StatefulWidget {
  /// Name of the person currently typing.
  final String? typerName;

  /// Whether the typing indicator should be visible.
  final bool isVisible;

  /// Custom color for the dots. Defaults to Coffee Bean color.
  final Color? dotColor;

  const TypingIndicator({
    super.key,
    this.typerName,
    required this.isVisible,
    this.dotColor,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _dotController;
  late Animation<double> _fadeAnimation;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();

    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Dot bounce animation controller
    _dotController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Create staggered animations for each dot
    _dotAnimations = List.generate(3, (index) {
      final startInterval = index * 0.15;
      final endInterval = startInterval + 0.5;
      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 0, end: -8)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: -8, end: 0)
              .chain(CurveTween(curve: Curves.bounceOut)),
          weight: 50,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _dotController,
          curve: Interval(
            startInterval.clamp(0.0, 1.0),
            endInterval.clamp(0.0, 1.0),
          ),
        ),
      );
    });

    if (widget.isVisible) {
      _fadeController.forward();
      _dotController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant TypingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _fadeController.forward();
        _dotController.repeat();
      } else {
        _fadeController.reverse();
        _dotController.stop();
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
        ).animate(_fadeAnimation),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dots container with glass effect
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.15),
                          Colors.white.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        return AnimatedBuilder(
                          animation: _dotAnimations[index],
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _dotAnimations[index].value),
                              child: Container(
                                margin: EdgeInsets.only(
                                  right: index < 2 ? 4 : 0,
                                ),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: widget.dotColor ?? AppColors.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (widget.dotColor ?? AppColors.primary)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Typer name
              if (widget.typerName != null)
                Text(
                  '${widget.typerName} is typing...',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Controller for managing typing state with Supabase Realtime.
///
/// Handles broadcasting and receiving typing status updates.
class TypingIndicatorController {
  final String roomId;
  final String userId;
  final String userName;

  /// Current typing users in the room (excluding self).
  final ValueNotifier<List<TypingUser>> typingUsers = ValueNotifier([]);

  /// Whether anyone is currently typing.
  bool get isAnyoneTyping => typingUsers.value.isNotEmpty;

  /// Display name for the typing indicator.
  String? get typingDisplayName {
    final users = typingUsers.value;
    if (users.isEmpty) return null;
    if (users.length == 1) return users.first.name;
    if (users.length == 2) {
      return '${users[0].name} and ${users[1].name}';
    }
    return '${users[0].name} and ${users.length - 1} others';
  }

  TypingIndicatorController({
    required this.roomId,
    required this.userId,
    required this.userName,
  });

  /// Update typing users list (called when receiving presence updates).
  void updateTypingUsers(List<TypingUser> users) {
    // Filter out current user and stale entries (>5 seconds old)
    final now = DateTime.now().millisecondsSinceEpoch;
    final activeUsers = users
        .where((u) => u.id != userId && now - u.timestamp < 5000)
        .toList();
    typingUsers.value = activeUsers;
  }

  /// Clean up resources.
  void dispose() {
    typingUsers.dispose();
  }
}

/// Represents a user who is currently typing.
class TypingUser {
  final String id;
  final String name;
  final int timestamp;

  const TypingUser({
    required this.id,
    required this.name,
    required this.timestamp,
  });

  factory TypingUser.fromJson(Map<String, dynamic> json) {
    return TypingUser(
      id: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      timestamp: json['timestamp'] as int? ?? 0,
    );
  }
}
