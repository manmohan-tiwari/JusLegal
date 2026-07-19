import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:juslegal/screens/ai_legal_chat_screen.dart';

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

  const FloatingAIButton({Key? key, required this.userName}) : super(key: key);

  @override
  State<FloatingAIButton> createState() => _FloatingAIButtonState();
}

class _FloatingAIButtonState extends State<FloatingAIButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

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

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
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
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
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
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _rotateAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer rotating gradient ring
                  Transform.rotate(
                    angle: _rotateAnimation.value,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            const Color(0xFF1A237E).withOpacity(0),
                            const Color(0xFF3949AB),
                            const Color(0xFF7C4DFF),
                            const Color(0xFF1A237E).withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Inner button
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1A237E),
                          Color(0xFF3949AB),
                          Color(0xFF5C6BC0),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3949AB).withOpacity(0.5),
                          blurRadius: 16,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const _AIBotIcon(),
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
    final accent = Paint()..color = const Color(0xFF7C4DFF);
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
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
        ..color = const Color(0xFF7C4DFF)
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