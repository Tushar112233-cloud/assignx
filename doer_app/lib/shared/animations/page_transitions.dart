/// Custom page transition classes for GoRouter navigation.
///
/// Provides three transition styles matching the user_app design system:
/// - [FadeScalePage] for auth screens (fade + subtle scale up)
/// - [SlideRightPage] for forward navigation (slide from right)
/// - [SlideUpPage] for modal-like screens (slide from bottom)
///
/// All transitions use a 300ms duration with [Curves.easeOutCubic] for
/// smooth deceleration, and respect system reduced-motion preferences.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Fade-in with subtle scale-up transition for auth screens.
///
/// Animates from 0.95 -> 1.0 scale and 0.0 -> 1.0 opacity over 300ms.
/// Ideal for login, register, and similar entry-point screens.
///
/// Example:
/// ```dart
/// GoRoute(
///   path: '/login',
///   pageBuilder: (context, state) => FadeScalePage(
///     key: state.pageKey,
///     child: const LoginScreen(),
///   ),
/// ),
/// ```
class FadeScalePage<T> extends CustomTransitionPage<T> {
  /// Creates a fade-scale transition page.
  ///
  /// [child] is the destination page widget.
  /// [key] is an optional key for the page (typically [GoRouterState.pageKey]).
  FadeScalePage({required super.child, super.key})
      : super(
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Respect system reduced-motion preference.
            if (MediaQuery.of(context).disableAnimations) {
              return child;
            }

            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );

            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(curved),
                child: child,
              ),
            );
          },
        );
}

/// Slide-from-right transition for forward navigation.
///
/// Slides the incoming page from the right edge with a concurrent fade.
/// Ideal for navigating between screens in a hierarchical flow
/// (e.g., project list -> project detail -> workspace).
///
/// Example:
/// ```dart
/// GoRoute(
///   path: '/projects/:id',
///   pageBuilder: (context, state) => SlideRightPage(
///     key: state.pageKey,
///     child: ProjectDetailScreen(projectId: state.pathParameters['id']!),
///   ),
/// ),
/// ```
class SlideRightPage<T> extends CustomTransitionPage<T> {
  /// Creates a slide-right transition page.
  ///
  /// [child] is the destination page widget.
  /// [key] is an optional key for the page (typically [GoRouterState.pageKey]).
  SlideRightPage({required super.child, super.key})
      : super(
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (MediaQuery.of(context).disableAnimations) {
              return child;
            }

            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );

            final slideAnimation = Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(curved);

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: curved,
                child: child,
              ),
            );
          },
        );
}

/// Slide-from-bottom transition for modal-like screens.
///
/// Slides the incoming page up from the bottom edge. Ideal for
/// screens that feel like overlays or detail modals (e.g., submit work,
/// revision details).
///
/// Example:
/// ```dart
/// GoRoute(
///   path: '/projects/:id/submit',
///   pageBuilder: (context, state) => SlideUpPage(
///     key: state.pageKey,
///     child: SubmitWorkScreen(projectId: state.pathParameters['id']!),
///   ),
/// ),
/// ```
class SlideUpPage<T> extends CustomTransitionPage<T> {
  /// Creates a slide-up transition page.
  ///
  /// [child] is the destination page widget.
  /// [key] is an optional key for the page (typically [GoRouterState.pageKey]).
  SlideUpPage({required super.child, super.key})
      : super(
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (MediaQuery.of(context).disableAnimations) {
              return child;
            }

            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );

            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(curved);

            return SlideTransition(
              position: slideAnimation,
              child: child,
            );
          },
        );
}
