/// Animation utilities and page transitions for the AssignX app.
///
/// This module provides:
/// - [CommonAnimations] - Widget extension with common animation effects
/// - [PageTransitions] - Custom page route builders for navigation
/// - [StaggerAnimationController] - Utility for staggered list animations
/// - [AppCurves] - Custom animation curves matching user-web design
/// - [AppPageTransitions] - GoRouter page transition builders
///
/// Example usage:
/// ```dart
/// // Widget animations
/// Container().fadeInSlideUp();
/// Container().springScale();
///
/// // Page transitions with Navigator
/// Navigator.push(context, FadeScalePageRoute(page: MyScreen()));
///
/// // Page transitions with GoRouter
/// GoRoute(
///   path: '/details',
///   pageBuilder: (context, state) => AppPageTransitions.fadeScale(
///     child: DetailsScreen(),
///     state: state,
///   ),
/// );
///
/// // Staggered list animations
/// final stagger = StaggerAnimationController(itemCount: items.length);
/// ListView.builder(
///   itemBuilder: (context, index) =>
///     stagger.buildAnimatedItem(index, ItemWidget()),
/// );
/// ```
library;

export 'common_animations.dart';
export 'page_transitions.dart';
