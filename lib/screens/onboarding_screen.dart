import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_config.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundFadeController;
  late AnimationController _bookScaleController;
  late AnimationController _titleSlideController;
  late AnimationController _subtitleFadeController;
  late AnimationController _lineScaleController;
  late AnimationController _pill1FadeController;
  late AnimationController _pill2FadeController;
  late AnimationController _pill3FadeController;
  late AnimationController _bottomFadeController;

  late Animation<double> _backgroundFade;
  late Animation<double> _bookScale;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<double> _lineScale;
  late Animation<double> _pill1Fade;
  late Animation<double> _pill2Fade;
  late Animation<double> _pill3Fade;
  late Animation<double> _bottomFade;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
  }

  void _initAnimations() {
    _backgroundFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _backgroundFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundFadeController, curve: Curves.easeIn),
    );

    _bookScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bookScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bookScaleController, curve: Curves.elasticOut),
    );

    _titleSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleSlideController, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _titleSlideController, curve: Curves.easeOut));

    _subtitleFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _subtitleFadeController, curve: Curves.easeOut),
    );

    _lineScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _lineScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lineScaleController, curve: Curves.easeOut),
    );

    _pill1FadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pill1Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pill1FadeController, curve: Curves.easeOut),
    );

    _pill2FadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pill2Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pill2FadeController, curve: Curves.easeOut),
    );

    _pill3FadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pill3Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pill3FadeController, curve: Curves.easeOut),
    );

    _bottomFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bottomFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bottomFadeController, curve: Curves.easeOut),
    );
  }

  void _startAnimationSequence() async {
    // 0ms: Screen starts pitch black (opacity 0) - initial state
    await Future.delayed(Duration.zero);

    // 300ms: Background fades in to Color(0xFF1F2937)
    await Future.delayed(const Duration(milliseconds: 300));
    _backgroundFadeController.forward();

    // 600ms: Book scales from 0.0 to 1.0
    await Future.delayed(const Duration(milliseconds: 300));
    _bookScaleController.forward();

    // 1800ms: Title fades + slides up
    await Future.delayed(const Duration(milliseconds: 1200));
    _titleSlideController.forward();

    // 2200ms: Subtitle fades in
    await Future.delayed(const Duration(milliseconds: 400));
    _subtitleFadeController.forward();

    // 2800ms: Line scales width
    await Future.delayed(const Duration(milliseconds: 600));
    _lineScaleController.forward();

    // 3200ms: Feature pills fade in staggered
    await Future.delayed(const Duration(milliseconds: 400));
    _pill1FadeController.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    _pill2FadeController.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    _pill3FadeController.forward();

    // 4600ms: Bottom area fades in
    await Future.delayed(const Duration(milliseconds: 1100));
    _bottomFadeController.forward();
  }

  @override
  void dispose() {
    _backgroundFadeController.dispose();
    _bookScaleController.dispose();
    _titleSlideController.dispose();
    _subtitleFadeController.dispose();
    _lineScaleController.dispose();
    _pill1FadeController.dispose();
    _pill2FadeController.dispose();
    _pill3FadeController.dispose();
    _bottomFadeController.dispose();
    super.dispose();
  }

  Future<void> _handleGetStarted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    await prefs.setBool('disclaimer_shown', true);
    if (mounted) {
      context.go('/login');
    }
  }

  void _showHowItWorks() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: const Radius.circular(16)),
      ),
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHowItWorks(),
              const SizedBox(height: 32),
              _buildDisclaimer(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleGetStarted();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052CC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Got It, Let\'s Begin',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2937),
      body: AnimatedBuilder(
        animation: _backgroundFade,
        builder: (context, child) {
          return Container(
            color: const Color(0xFF1F2937)
                .withValues(alpha: _backgroundFade.value),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBookAnimation(),
                          const SizedBox(height: 32),
                          _buildTitle(),
                          const SizedBox(height: 8),
                          _buildSubtitle(),
                          const SizedBox(height: 16),
                          _buildLine(),
                          const SizedBox(height: 24),
                          _buildFeaturePills(),
                          const SizedBox(height: 48),
                          _buildBottomButtons(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookAnimation() {
    return AnimatedBuilder(
      animation: _bookScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _bookScale.value,
          child: const _ConstitutionBookAnimation(),
        );
      },
    );
  }

  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: _titleSlideController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _titleFade,
          child: SlideTransition(
            position: _titleSlide,
            child: Image.asset(
              AppConfig.appLogoAsset,
              height: 86,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubtitle() {
    return AnimatedBuilder(
      animation: _subtitleFade,
      builder: (context, child) {
        return FadeTransition(
          opacity: _subtitleFade,
          child: Text(
            'Know Your Rights. Take Action.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLine() {
    return AnimatedBuilder(
      animation: _lineScale,
      builder: (context, child) {
        return Center(
          child: Container(
            width: 48 * _lineScale.value,
            height: 2,
            color: const Color(0xFFFCA311),
          ),
        );
      },
    );
  }

  Widget _buildFeaturePills() {
    return Column(
      children: [
        _buildFeaturePill(
          icon: Icons.auto_awesome_outlined,
          text: 'AI-Powered Analysis',
          animation: _pill1Fade,
        ),
        const SizedBox(height: 12),
        _buildFeaturePill(
          icon: Icons.balance_rounded,
          text: 'Indian Consumer Law',
          animation: _pill2Fade,
        ),
        const SizedBox(height: 12),
        _buildFeaturePill(
          icon: Icons.checklist_rounded,
          text: 'Instant Action Plan',
          animation: _pill3Fade,
        ),
      ],
    );
  }

  Widget _buildFeaturePill({
    required IconData icon,
    required String text,
    required Animation<double> animation,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return FadeTransition(
          opacity: animation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButtons() {
    return AnimatedBuilder(
      animation: _bottomFade,
      builder: (context, child) {
        return FadeTransition(
          opacity: _bottomFade,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _handleGetStarted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052CC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Get Started',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _showHowItWorks,
                child: Text(
                  'View How It Works',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHowItWorks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How It Works',
          style: GoogleFonts.merriweather(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 24),
        Column(
          children: [
            _buildStep(
              stepNumber: 1,
              title: 'Describe your problem',
              subtitle: 'Tell us what happened in plain language',
              showLine: true,
            ),
            const SizedBox(height: 24),
            _buildStep(
              stepNumber: 2,
              title: 'AI analyses Indian law',
              subtitle:
                  'We check Consumer Protection Act 2019 and relevant regulations',
              showLine: true,
            ),
            const SizedBox(height: 24),
            _buildStep(
              stepNumber: 3,
              title: 'Get your action plan',
              subtitle:
                  'Receive steps, authorities to contact and a ready complaint letter',
              showLine: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.balance_rounded,
          size: 56,
          color: const Color(0xFFFCA311),
        ),
        const SizedBox(height: 16),
        Text(
          'Before You Begin',
          style: GoogleFonts.merriweather(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please read carefully',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 24),
        _buildDisclaimerPoint(
          'AI-generated guidance only — not legal advice',
        ),
        _buildDisclaimerPoint(
          'Always verify with official sources',
        ),
        _buildDisclaimerPoint(
          'For court proceedings consult a qualified advocate',
        ),
        _buildDisclaimerPoint(
          'JusLegal does not create an attorney-client relationship',
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFCA311).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFFCA311).withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            'By using JusLegal, you acknowledge that you have read and understood this disclaimer.',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF1F2937),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep({
    required int stepNumber,
    required String title,
    required String subtitle,
    required bool showLine,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 32,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (showLine)
                Positioned(
                  top: 16,
                  child: Container(
                    width: 2,
                    height: 56,
                    color: const Color(0xFFE5E7EB),
                  ),
                ),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF0052CC),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$stepNumber',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimerPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: const Color(0xFFFCA311),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConstitutionBookAnimation extends StatefulWidget {
  const _ConstitutionBookAnimation();

  @override
  State<_ConstitutionBookAnimation> createState() =>
      _ConstitutionBookAnimationState();
}

class _ConstitutionBookAnimationState extends State<_ConstitutionBookAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _animation = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 180,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _ConstitutionBookPainter(animationValue: _animation.value),
          );
        },
      ),
    );
  }
}

class _ConstitutionBookPainter extends CustomPainter {
  final double animationValue;

  _ConstitutionBookPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw golden glow behind book
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFCA311).withValues(alpha: 0.15 * animationValue),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: 70,
        ),
      );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      70,
      glowPaint,
    );

    // Spine
    final spinePaint = Paint()
      ..color = const Color(0xFF6B3A1F)
      ..style = PaintingStyle.fill;
    final spineRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, 14, 160),
      const Radius.circular(4),
    );
    canvas.drawRRect(spineRRect, spinePaint);

    // Cover with gradient
    final coverGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [Color(0xFFFF9933), Color(0xFFE07B00)],
    );
    final coverPaint = Paint()
      ..shader = coverGradient.createShader(
        Rect.fromLTWH(14, 0, 106, 160),
      );
    final coverRRect = RRect.fromRectAndCorners(
      const Rect.fromLTWH(14, 0, 106, 160),
      topLeft: const Radius.circular(0),
      bottomLeft: const Radius.circular(0),
      topRight: const Radius.circular(8),
      bottomRight: const Radius.circular(8),
    );
    canvas.drawRRect(coverRRect, coverPaint);

    // Open pages effect (3 thin pages slightly offset)
    final pagePaint = Paint()
      ..color = const Color(0xFFFFFDE7)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 3; i++) {
      final pageOffset = 2.0 * (i + 1);
      final pageRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(14 + pageOffset, 2 + pageOffset * 0.5, 104 - pageOffset,
            156 - pageOffset),
        const Radius.circular(2),
      );
      canvas.drawRRect(pageRRect, pagePaint);
    }

    // Flutter animation for topmost page
    final flutterSkew = math.sin(animationValue * math.pi) * 0.05;
    canvas.save();
    canvas.translate(14.0 + 6.0, 2.0 + 3.0);
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateY(flutterSkew);
    canvas.transform(matrix.storage);
    canvas.translate(-(14.0 + 6.0), -(2.0 + 3.0));
    final topPageRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(14.0 + 6.0, 2.0 + 3.0, 100, 152),
      const Radius.circular(2),
    );
    canvas.drawRRect(topPageRRect, pagePaint);
    canvas.restore();

    // Cover title - Hindi
    final hindiTextPainter = TextPainter(
      text: const TextSpan(
        text: 'भारत का\nसंविधान',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    hindiTextPainter.layout(maxWidth: 106);
    hindiTextPainter.paint(
      canvas,
      Offset(14 + (106 - hindiTextPainter.width) / 2, 20),
    );

    // English title
    final englishTextPainter = TextPainter(
      text: const TextSpan(
        text: 'CONSTITUTION\nOF INDIA',
        style: TextStyle(
          color: Colors.white,
          fontSize: 7,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    englishTextPainter.layout(maxWidth: 106);
    englishTextPainter.paint(
      canvas,
      Offset(14 + (106 - englishTextPainter.width) / 2, 55),
    );

    // Ashoka Chakra
    final chakraCenter = Offset(14 + 53, 120);
    final chakraRadius = 16.0;
    final chakraPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(chakraCenter, chakraRadius, chakraPaint);

    // 24 evenly spaced lines from center to circle edge
    final spokePaint = Paint()
      ..color = const Color(0xFF000080).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (int i = 0; i < 24; i++) {
      final angle = (i * 15) * math.pi / 180;
      final startX = chakraCenter.dx + math.cos(angle) * 2;
      final startY = chakraCenter.dy + math.sin(angle) * 2;
      final endX = chakraCenter.dx + math.cos(angle) * (chakraRadius - 2);
      final endY = chakraCenter.dy + math.sin(angle) * (chakraRadius - 2);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), spokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConstitutionBookPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
