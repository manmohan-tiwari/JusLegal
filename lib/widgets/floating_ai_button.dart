import 'package:flutter/material.dart';
import 'package:juslegal/screens/ai_legal_chat_screen.dart';
import 'package:juslegal/core/core.dart';

/// Floating AI Assistant Button
/// Place this widget in your Scaffold using a Stack or floatingActionButton
///
/// Usage in any screen:
/// ```dart
/// Scaffold(
///   body: YourScreenContent(),
///   floatingActionButton: FloatingAIButton(userName: 'Rahul'),
/// )
/// ```
class FloatingAIButton extends StatefulWidget {
  final String userName;

  const FloatingAIButton({super.key, required this.userName});

  @override
  State<FloatingAIButton> createState() => _FloatingAIButtonState();
}

class _FloatingAIButtonState extends State<FloatingAIButton>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _rotateController;
  late final Animation<double> _pulseAnimation;

  late final Widget _outerRing = Container(
    width: 64,
    height: 64,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: SweepGradient(
        colors: [
          AppColors.deepNavy.withValues(alpha: 0),
          AppColors.paleBlue,
          AppColors.mustardGold,
          AppColors.deepNavy.withValues(alpha: 0),
        ],
      ),
    ),
  );

  late final Widget _innerButton = Container(
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFC74F),
          AppColors.mustardGold,
          Color(0xFFE59F1C),
        ],
      ),
      boxShadow: const [
        BoxShadow(
          color: AppColors.shadowGold,
          blurRadius: 16,
          spreadRadius: 1,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: const _AIBotIcon(),
  );

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _openChat() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AILegalChatScreen(userName: widget.userName),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openChat,
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: SizedBox(
          width: 64,
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer rotating gradient ring rendered via GPU compositor
              RotationTransition(
                turns: _rotateController,
                child: _outerRing,
              ),
              // Inner static button
              _innerButton,
            ],
          ),
        ),
      ),
    );
  }
}

class _AIBotIcon extends StatelessWidget {
  const _AIBotIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BotFacePainter(),
      size: const Size(56, 56),
    );
  }
}

class _BotFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final white = Paint()..color = Colors.white;
    final accent = Paint()..color = AppColors.primaryNavy;
    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // Head outline (rounded rect)
    final headRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 1), width: 28, height: 24),
      const Radius.circular(8),
    );
    canvas.drawRRect(headRect, white);

    // Left eye
    canvas.drawCircle(Offset(cx - 6, cy - 1), 4, accent);
    canvas.drawCircle(Offset(cx - 6, cy - 1), 2, white);
    canvas.drawCircle(Offset(cx - 5.2, cy - 1.8), 0.8, accent);

    // Right eye
    canvas.drawCircle(Offset(cx + 6, cy - 1), 4, accent);
    canvas.drawCircle(Offset(cx + 6, cy - 1), 2, white);
    canvas.drawCircle(Offset(cx + 6.8, cy - 1.8), 0.8, accent);

    // Smile
    final smilePath = Path();
    smilePath.moveTo(cx - 6, cy + 5);
    smilePath.quadraticBezierTo(cx, cy + 9, cx + 6, cy + 5);
    canvas.drawPath(
      smilePath,
      Paint()
        ..color = AppColors.primaryNavy
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Antenna
    canvas.drawLine(
      Offset(cx, cy - 12),
      Offset(cx, cy - 17),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(cx, cy - 18), 2.5, glowPaint);
    canvas.drawCircle(Offset(cx, cy - 18), 1.5, accent);

    // Ears (small side bumps)
    canvas.drawCircle(Offset(cx - 14, cy + 1), 2.5, white);
    canvas.drawCircle(Offset(cx + 14, cy + 1), 2.5, white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

