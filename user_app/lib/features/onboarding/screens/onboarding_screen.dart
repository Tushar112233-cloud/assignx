import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/route_names.dart';

/// Onboarding carousel with 3 slides.
///
/// Beautiful curved design with gradient backgrounds, Lottie animations,
/// and step indicators.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;
  bool _userInteracted = false;

  /// Onboarding slides data.
  /// Each slide has gradient colors, title, subtitle, and Lottie animation URL.
  static const _pages = [
    {
      'gradientColors': [Color(0xFFEC407A), Color(0xFFF48FB1)], // Pink
      'title': 'Expert Help',
      'subtitle': 'Get professional assistance at your fingertips, anytime',
      'lottieUrl': 'https://lottie.host/715ac670-afd6-4524-986e-e00f6d039876/vOvWdIeO1B.json',
    },
    {
      'gradientColors': [Color(0xFF42A5F5), Color(0xFF90CAF9)], // Blue
      'title': 'Versatile Projects',
      'subtitle': 'From essays to presentations, we handle it all for you',
      'lottieUrl': 'https://lottie.host/5533bf32-9e5e-4767-82d9-d08a4fde91b8/fHuLWM1ODi.json',
    },
    {
      'gradientColors': [Color(0xFF66BB6A), Color(0xFFA5D6A7)], // Green (changed from pink)
      'title': 'Your Journey Starts',
      'subtitle': 'Join thousands of students achieving academic success',
      'lottieUrl': 'https://lottie.host/f5451620-d8db-4e9d-b228-de3b65c936d7/uSnBXiDaWD.json',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  /// Start auto-scroll timer.
  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      // Stop auto-scroll if user has manually interacted
      if (_userInteracted) {
        timer.cancel();
        return;
      }

      if (_currentPage < _pages.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      } else {
        // Loop back to first page
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// Marks onboarding as complete and navigates to login.
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (mounted) {
      context.go(RouteNames.login);
    }
  }

  /// Moves to next page or completes onboarding if on last page.
  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topSectionHeight = screenHeight * 0.55;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated gradient background that smoothly transitions
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: _AnimatedGradientBackground(
              currentPage: _currentPage,
              pages: _pages,
              topSectionHeight: topSectionHeight,
            ),
          ),

          // Page view for swipeable Lottie content only
          GestureDetector(
            onHorizontalDragStart: (_) {
              // User started swiping - stop auto-scroll
              setState(() => _userInteracted = true);
            },
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                  _userInteracted = true; // Mark as interacted on page change
                });
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];

                return _OnboardingLottieContent(
                  topSectionHeight: topSectionHeight,
                  lottieUrl: page['lottieUrl'] as String,
                  isActive: index == _currentPage,
                );
              },
            ),
          ),

          // Bottom white section with content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomContent(
              currentPage: _currentPage,
              totalPages: _pages.length,
              title: _pages[_currentPage]['title'] as String,
              subtitle: _pages[_currentPage]['subtitle'] as String,
              onNext: _nextPage,
              onSkip: _completeOnboarding,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated gradient background that smoothly transitions between pages.
class _AnimatedGradientBackground extends StatefulWidget {
  final int currentPage;
  final List<Map<String, dynamic>> pages;
  final double topSectionHeight;

  const _AnimatedGradientBackground({
    required this.currentPage,
    required this.pages,
    required this.topSectionHeight,
  });

  @override
  State<_AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends State<_AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation1;
  late Animation<Color?> _colorAnimation2;
  List<Color> _previousColors = [];
  List<Color> _currentColors = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _currentColors =
        widget.pages[widget.currentPage]['gradientColors'] as List<Color>;
    _previousColors = _currentColors;

    _setupAnimations();
  }

  void _setupAnimations() {
    _colorAnimation1 = ColorTween(
      begin: _previousColors[0],
      end: _currentColors[0],
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _colorAnimation2 = ColorTween(
      begin: _previousColors[1],
      end: _currentColors[1],
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_AnimatedGradientBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage) {
      _previousColors = _currentColors;
      _currentColors =
          widget.pages[widget.currentPage]['gradientColors'] as List<Color>;

      _setupAnimations();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          children: [
            // Gradient top section with curved bottom
            ClipPath(
              clipper: _CurvedBottomClipper(),
              child: Container(
                height: widget.topSectionHeight + 40, // Extra for curve
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _colorAnimation1.value ?? _currentColors[0],
                      _colorAnimation2.value ?? _currentColors[1],
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative doodle elements
                    ..._buildDoodleElements(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build decorative doodle elements (circles, rings, dots)
  List<Widget> _buildDoodleElements() {
    return [
      // Large ring - top left
      Positioned(
        top: 40,
        left: -30,
        child: _DoodleRing(size: 80, strokeWidth: 3),
      ),
      // Small filled circle - top right
      Positioned(
        top: 60,
        right: 40,
        child: _DoodleCircle(size: 20),
      ),
      // Medium ring - right side
      Positioned(
        top: 150,
        right: -20,
        child: _DoodleRing(size: 60, strokeWidth: 2),
      ),
      // Dots cluster - left side
      Positioned(
        top: 200,
        left: 30,
        child: _DoodleDots(),
      ),
      // Small circle - bottom left
      Positioned(
        bottom: 120,
        left: 60,
        child: _DoodleCircle(size: 14),
      ),
      // Squiggly line - top center
      Positioned(
        top: 90,
        left: 100,
        child: _DoodleSquiggle(),
      ),
      // Cross/plus - right center
      Positioned(
        top: 280,
        right: 50,
        child: _DoodleCross(size: 24),
      ),
      // Small ring - bottom right
      Positioned(
        bottom: 100,
        right: 80,
        child: _DoodleRing(size: 30, strokeWidth: 2),
      ),
      // Triangle outline - left
      Positioned(
        top: 320,
        left: 20,
        child: _DoodleTriangle(size: 28),
      ),
      // Tiny dots scattered
      Positioned(
        top: 120,
        right: 120,
        child: _DoodleCircle(size: 8),
      ),
      Positioned(
        bottom: 160,
        left: 120,
        child: _DoodleCircle(size: 10),
      ),
    ];
  }
}

/// Doodle ring (circle outline)
class _DoodleRing extends StatelessWidget {
  final double size;
  final double strokeWidth;

  const _DoodleRing({required this.size, required this.strokeWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: strokeWidth,
        ),
      ),
    );
  }
}

/// Doodle filled circle
class _DoodleCircle extends StatelessWidget {
  final double size;

  const _DoodleCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.25),
      ),
    );
  }
}

/// Doodle dots cluster
class _DoodleDots extends StatelessWidget {
  const _DoodleDots();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: Stack(
        children: [
          Positioned(top: 0, left: 0, child: _dot()),
          Positioned(top: 0, right: 0, child: _dot()),
          Positioned(bottom: 0, left: 0, child: _dot()),
          Positioned(bottom: 0, right: 0, child: _dot()),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot() => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.25),
        ),
      );
}

/// Doodle squiggle/wave line
class _DoodleSquiggle extends StatelessWidget {
  const _DoodleSquiggle();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(50, 20),
      painter: _SquigglePainter(),
    );
  }
}

class _SquigglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height / 2);
    path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, size.height / 2);
    path.quadraticBezierTo(size.width * 0.75, size.height, size.width, size.height / 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Doodle cross/plus
class _DoodleCross extends StatelessWidget {
  final double size;

  const _DoodleCross({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CrossPainter(),
    );
  }
}

class _CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Vertical line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    // Horizontal line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Doodle triangle outline
class _DoodleTriangle extends StatelessWidget {
  final double size;

  const _DoodleTriangle({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TrianglePainter(),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Lottie animation content centered in the curved area.
class _OnboardingLottieContent extends StatelessWidget {
  final double topSectionHeight;
  final String lottieUrl;
  final bool isActive;

  const _OnboardingLottieContent({
    required this.topSectionHeight,
    required this.lottieUrl,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: topSectionHeight + 40,
          child: SafeArea(
            bottom: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: _LottieAnimation(
                  url: lottieUrl,
                  isActive: isActive,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Lottie animation widget using network URLs.
class _LottieAnimation extends StatelessWidget {
  final String url;
  final bool isActive;

  const _LottieAnimation({
    required this.url,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    // Make size responsive - 65% of screen width, max 300px
    final screenWidth = MediaQuery.of(context).size.width;
    final size = (screenWidth * 0.65).clamp(200.0, 300.0);

    return SizedBox(
      width: size,
      height: size,
      child: Lottie.network(
        url,
        fit: BoxFit.contain,
        animate: isActive,
        repeat: true,
        errorBuilder: (context, error, stackTrace) {
          // Fallback if Lottie fails to load
          return Icon(
            Icons.image_outlined,
            size: size * 0.5,
            color: Colors.white.withValues(alpha: 0.5),
          );
        },
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.easeOutBack,
        );
  }
}

/// Bottom section with title, subtitle, next button, and dots.
class _BottomContent extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final String title;
  final String subtitle;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _BottomContent({
    required this.currentPage,
    required this.totalPages,
    required this.title,
    required this.subtitle,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == totalPages - 1;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24), // Reduced top padding from 50 to 32
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          // Title - prominent heading
          Text(
            title,
            style: AppTextStyles.displayMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 32,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          )
              .animate(key: ValueKey('title-$currentPage'))
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.2, end: 0, duration: 300.ms),

          const SizedBox(height: 12),

          // Subtitle - caption below title
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          )
              .animate(key: ValueKey('subtitle-$currentPage'))
              .fadeIn(delay: 100.ms, duration: 300.ms)
              .slideY(begin: 0.1, end: 0, duration: 300.ms),

          const SizedBox(height: 32),

          // Next button
          _NextButton(
            onPressed: onNext,
            isLastPage: isLastPage,
          ).animate().scale(delay: 200.ms, duration: 300.ms),

          const SizedBox(height: 20),

          // Page indicator dots
          _PageDots(
            currentPage: currentPage,
            totalPages: totalPages,
          ).animate().fadeIn(delay: 300.ms, duration: 300.ms),

          // Skip to sign-in link (not shown on last page)
          if (!isLastPage) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => GoRouter.of(context).go(RouteNames.signin),
              child: Text(
                'Already have an account? Sign in',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 300.ms),
          ],
        ],
        ),
      ),
    );
  }
}

/// Next/Get Started button.
class _NextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLastPage;

  const _NextButton({
    required this.onPressed,
    required this.isLastPage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLastPage) {
      // "Get Started" pill button for last page
      return GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            'Get Started',
            style: AppTextStyles.labelLarge.copyWith(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    // Circular arrow button for other pages
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2196F3).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_forward,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

/// Page indicator dots.
class _PageDots extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const _PageDots({
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.textPrimary
                : AppColors.textSecondary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

/// Custom clipper for curved bottom edge.
class _CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);

    // Create smooth curve
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 60,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
