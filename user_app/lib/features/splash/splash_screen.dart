import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/route_names.dart';
import '../../core/storage/token_storage.dart';
import '../../providers/auth_provider.dart';

/// Splash screen with animated logo and auth state check.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    // Check if user has stored tokens
    try {
      final hasTokens = await TokenStorage.hasTokens();
      if (!mounted) return;

      if (hasTokens) {
        // Wait for the auth provider to settle
        for (int i = 0; i < 20; i++) {
          final authState = ref.read(authStateProvider);
          if (!authState.isLoading) {
            final isAuthed = authState.valueOrNull?.isAuthenticated == true;
            if (isAuthed) {
              debugPrint('SplashScreen: Auth settled, navigating to home');
              context.go(RouteNames.home);
              return;
            } else {
              // Tokens were invalid/expired, clear and go to login
              debugPrint('SplashScreen: Auth failed, clearing tokens');
              await TokenStorage.clearTokens();
              break;
            }
          }
          await Future.delayed(const Duration(milliseconds: 250));
          if (!mounted) return;
        }
      }
    } catch (e) {
      debugPrint('SplashScreen: Auth check error: $e');
    }

    if (!mounted) return;

    // Check if onboarding has been completed
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_complete') ?? false;

    if (!mounted) return;
    context.go(onboardingDone ? RouteNames.login : RouteNames.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.85),
              const Color(0xFF9C27B0).withValues(alpha: 0.4),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'AssignX',
                  style: AppTextStyles.displayLarge.copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      curve: Curves.easeOut,
                    ),
                const SizedBox(height: 16),
                Text(
                  'Your Task, Our Expertise',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    letterSpacing: 0.5,
                  ),
                )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.2, end: 0, duration: 500.ms),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    .animate(delay: 800.ms)
                    .fadeIn(duration: 300.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
