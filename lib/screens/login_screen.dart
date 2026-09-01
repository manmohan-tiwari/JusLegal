import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:juslegal/l10n/gen/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:juslegal/core/core.dart';
import '../services/auth_handler.dart';
import '../widgets/loading_widget.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final TextEditingController _phoneController;
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _termsRecognizer = TapGestureRecognizer()..onTap = _openTerms;
    _privacyRecognizer = TapGestureRecognizer()..onTap = _openPrivacy;

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _phoneController.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  Future<void> _openTerms() async {
    final uri = Uri.parse(AppConfig.termsOfServiceUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openPrivacy() async {
    final uri = Uri.parse(AppConfig.privacyPolicyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
      if (!mounted) return;
      context.go('/home');
    } catch (error) {
      if (!mounted) return;
      final message = ref.read(authProvider).error ?? error.toString();
      setState(() {
        _localError = message;
      });
      _showMessage(message);
    }
  }

  Future<void> _handleOtpFlow() async {
    final l10n = AppLocalizations.of(context);
    final phoneText =
        _phoneController.text.replaceAll(RegExp(r'\s+'), '').trim();
    if (phoneText.length != 10 || !RegExp(r'^\d{10}$').hasMatch(phoneText)) {
      setState(() {
        _localError = l10n.validPhoneNumberError;
      });
      return;
    }

    setState(() {
      _localError = null;
    });

    await ref.read(authProvider.notifier).verifyPhone(
      '+91$phoneText',
      (verificationId) {
        if (context.mounted) {
          _showMessage(l10n.otpSentSuccessfully);
          context.push('/otp', extra: {
            'verificationId': verificationId,
            'phoneNumber': phoneText,
          });
        }
      },
      (error) {
        if (!mounted) return;
        setState(() {
          _localError = error;
        });
        _showMessage(error);
      },
      (_) {
        if (context.mounted) {
          _showMessage(l10n.phoneNumberVerifiedSuccessfully);
          context.go('/home');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final displayError = authState.error ?? _localError;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final size = MediaQuery.of(context).size;
    final compact = size.width < 420;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: _LawLibraryBackdrop()),
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  compact ? 18 : 24,
                  compact ? 20 : 28,
                  compact ? 18 : 24,
                  viewInsets + 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: size.height - (compact ? 40 : 56),
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 450),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              _TopBrandLockup(compact: compact),
                              const SizedBox(height: 24),
                              _AuthCard(
                                isLoading: isLoading,
                                compact: compact,
                                phoneController: _phoneController,
                                errorText: displayError,
                                onGoogleTap: _handleGoogleSignIn,
                                onAppleTap: () =>
                                    _showMessage(l10n.appleSignInSoon),
                                onEmailTap: () => context.push('/email-auth'),
                                onHelpTap: () => _showMessage(
                                  l10n.reachUsAt(AppConfig.supportEmail),
                                ),
                                onOtpTap: _handleOtpFlow,
                              ),
                              const SizedBox(height: 18),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: GoogleFonts.inter(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      height: 1.55,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: l10n.byContinuingYouAgreeToOur,
                                      ),
                                      TextSpan(
                                        text: l10n.terms,
                                        recognizer: _termsRecognizer,
                                        style: GoogleFonts.inter(
                                          color: AppColors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const TextSpan(text: ' & '),
                                      TextSpan(
                                        text: l10n.privacyPolicy,
                                        recognizer: _privacyRecognizer,
                                        style: GoogleFonts.inter(
                                          color: AppColors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const TextSpan(text: '.'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.white.withValues(alpha: 0.72),
                child: _LoadingMessage(message: l10n.authenticating),
              ),
            ),
        ],
      ),
    );
  }
}

class _TopBrandLockup extends StatelessWidget {
  final bool compact;

  const _TopBrandLockup({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: compact ? 74 : 82,
          height: compact ? 74 : 82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFD982), Color(0xFFB78123)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33B78123),
                blurRadius: 26,
                offset: Offset(0, 14),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: ClipOval(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.balance_rounded,
                color: AppColors.primary,
                size: 42,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'JusLegal. Your rights, our duty.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: compact ? 24 : 28,
            height: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context).secureAccessPortal,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: compact ? 14 : 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AuthCard extends StatelessWidget {
  final bool isLoading;
  final bool compact;
  final TextEditingController phoneController;
  final String? errorText;
  final Future<void> Function() onGoogleTap;
  final VoidCallback onAppleTap;
  final VoidCallback onEmailTap;
  final VoidCallback onHelpTap;
  final Future<void> Function() onOtpTap;

  const _AuthCard({
    required this.isLoading,
    required this.compact,
    required this.phoneController,
    required this.errorText,
    required this.onGoogleTap,
    required this.onAppleTap,
    required this.onEmailTap,
    required this.onHelpTap,
    required this.onOtpTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: AppColors.border,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowBlack,
                blurRadius: 36,
                offset: Offset(0, 18),
              ),
            ],
          ),
          child: Stack(
            children: [
              const Positioned(
                right: -8,
                bottom: -10,
                child: IgnorePointer(
                  child: _CardDecoration(),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  compact ? 20 : 26,
                  compact ? 22 : 28,
                  compact ? 20 : 26,
                  compact ? 18 : 22,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(text: l10n.continueWith),
                    const SizedBox(height: 14),
                    _ProviderButton(
                      label: l10n.continueWithGoogle,
                      borderColor: const Color(0xFFBED7FF),
                      icon: const _GoogleMark(),
                      onTap: isLoading ? null : onGoogleTap,
                    ),
                    const SizedBox(height: 12),
                    _ProviderButton(
                      label: l10n.continueWithApple,
                      borderColor: const Color(0xFFD9DEE7),
                      icon: const Icon(
                        Icons.apple,
                        color: Colors.black,
                        size: 22,
                      ),
                      onTap: isLoading ? null : onAppleTap,
                    ),
                    const SizedBox(height: 22),
                    const _Separator(),
                    const SizedBox(height: 22),
                    Text(
                      l10n.signInInstantlyWithPhoneOtp,
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: compact ? 16 : 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      enabled: !isLoading,
                      maxLength: 10,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: l10n.enterYourPhoneNumber,
                        hintStyle: GoogleFonts.inter(
                          color: AppColors.grey500,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: const Icon(
                          Icons.phone_iphone_rounded,
                          color: AppColors.legalGold,
                        ),
                        prefixText: '+91 ',
                        prefixStyle: GoogleFonts.inter(
                          color: AppColors.legalGold,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceBright,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 18,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: AppColors.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: AppColors.legalGold,
                            width: 1.6,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : onOtpTap,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.legalGold,
                          disabledBackgroundColor: AppColors.legalGold.withValues(
                            alpha: 0.45,
                          ),
                          foregroundColor: const Color(0xFF0B0F19),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          l10n.sendOtp,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0B0F19),
                          ),
                        ),
                      ),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorText!,
                        style: GoogleFonts.inter(
                          color: AppColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isLoading ? null : onEmailTap,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              backgroundColor: AppColors.surfaceBright,
                              side: const BorderSide(
                                color: AppColors.border,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              l10n.continueWithEmail,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontSize: compact ? 12 : 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: isLoading ? null : onHelpTap,
                          style: TextButton.styleFrom(
                            minimumSize: const Size(92, 48),
                            foregroundColor: AppColors.legalGold,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            l10n.needHelp,
                            style: GoogleFonts.inter(
                              fontSize: compact ? 12 : 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: AppColors.grey600,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ProviderButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final Color borderColor;
  final VoidCallback? onTap;

  const _ProviderButton({
    required this.label,
    required this.icon,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: const Color(0xFF12284D),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: Color(0xFFDCE4F2),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: GoogleFonts.inter(
              color: AppColors.grey500,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: Color(0xFFDCE4F2),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return Text(
      'G',
      style: GoogleFonts.notoSans(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF4285F4),
      ),
    );
  }
}

class _CardDecoration extends StatelessWidget {
  const _CardDecoration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 160,
      child: CustomPaint(
        painter: _CardDecorationPainter(),
      ),
    );
  }
}

class _CardDecorationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final goldPaint = Paint()
      ..color = const Color(0x1AB78123)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final wreathLeft = Path();
    wreathLeft.moveTo(size.width * 0.34, size.height * 0.22);
    wreathLeft.quadraticBezierTo(
      size.width * 0.13,
      size.height * 0.52,
      size.width * 0.28,
      size.height * 0.86,
    );
    canvas.drawPath(wreathLeft, goldPaint);

    final wreathRight = Path();
    wreathRight.moveTo(size.width * 0.56, size.height * 0.18);
    wreathRight.quadraticBezierTo(
      size.width * 0.82,
      size.height * 0.47,
      size.width * 0.63,
      size.height * 0.86,
    );
    canvas.drawPath(wreathRight, goldPaint);

    final columnPaint = Paint()
      ..color = const Color(0x149D7524)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0x26A97B26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final base = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.37, size.height * 0.44, 34, 66),
      const Radius.circular(8),
    );
    canvas.drawRRect(base, columnPaint);
    canvas.drawRRect(base, strokePaint);

    final topRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.32, size.height * 0.35, 46, 14),
      const Radius.circular(6),
    );
    final bottomRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.32, size.height * 0.96 - 14, 46, 14),
      const Radius.circular(6),
    );
    canvas.drawRRect(topRect, columnPaint);
    canvas.drawRRect(bottomRect, columnPaint);

    canvas.drawLine(
      Offset(size.width * 0.47, size.height * 0.30),
      Offset(size.width * 0.47, size.height * 0.22),
      strokePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.29, size.height * 0.33),
      Offset(size.width * 0.65, size.height * 0.33),
      strokePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.33),
      Offset(size.width * 0.28, size.height * 0.53),
      strokePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.59, size.height * 0.33),
      Offset(size.width * 0.66, size.height * 0.53),
      strokePaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.27, size.height * 0.57),
        width: 28,
        height: 12,
      ),
      strokePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.67, size.height * 0.57),
        width: 28,
        height: 12,
      ),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LawLibraryBackdrop extends StatelessWidget {
  const _LawLibraryBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF7FAFF),
                Color(0xFFE5EEFF),
                Color(0xFFD7E6FF),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _LibraryPainter(),
            ),
          ),
        ),
        Positioned(
          top: -60,
          right: -30,
          child: _BlurBlob(
            size: 200,
            colors: const [Color(0x55F7C562), Color(0x00F7C562)],
          ),
        ),
        Positioned(
          left: -40,
          bottom: 90,
          child: _BlurBlob(
            size: 220,
            colors: const [Color(0x660052CC), Color(0x000052CC)],
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
      ],
    );
  }
}

class _BlurBlob extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _BlurBlob({
    required this.size,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

class _LibraryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shelfPaint = Paint()
      ..color = const Color(0x1A24446F)
      ..style = PaintingStyle.fill;
    final accentPaint = Paint()
      ..color = const Color(0x112A74F5)
      ..style = PaintingStyle.fill;

    for (double y = size.height * 0.2; y < size.height; y += 138) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-20, y, size.width + 40, 10),
          const Radius.circular(8),
        ),
        shelfPaint,
      );
    }

    for (double x = 10; x < size.width; x += 36) {
      final bookHeight = 70 + ((x ~/ 36) % 4) * 18;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height * 0.24, 18, bookHeight.toDouble()),
          const Radius.circular(4),
        ),
        accentPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              x + 2, size.height * 0.59, 18, (bookHeight - 6).toDouble()),
          const Radius.circular(4),
        ),
        shelfPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LoadingMessage extends StatelessWidget {
  final String message;

  const _LoadingMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LoadingWidget(size: 40),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
