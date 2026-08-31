import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:juslegal/l10n/gen/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/config/theme_config.dart';
import '../core/constants/app_config.dart';
import '../services/auth_handler.dart';
import '../widgets/loading_widget.dart';

class LoginScreenNew extends ConsumerStatefulWidget {
  const LoginScreenNew({super.key});

  @override
  ConsumerState<LoginScreenNew> createState() => _LoginScreenNewState();
}

class _LoginScreenNewState extends ConsumerState<LoginScreenNew>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final TextEditingController _phoneController;
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;
  late final TapGestureRecognizer _legalDisclaimerRecognizer;
  String? _localError;
  bool _isPhoneTab = true;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _termsRecognizer = TapGestureRecognizer()..onTap = _openTerms;
    _privacyRecognizer = TapGestureRecognizer()..onTap = _openPrivacy;
    _legalDisclaimerRecognizer = TapGestureRecognizer()..onTap = _openLegalDisclaimer;

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
    _legalDisclaimerRecognizer.dispose();
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

  Future<void> _openLegalDisclaimer() async {
    // Navigate to legal disclaimer screen
    context.push('/legal-terms');
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
    // final l10n = AppLocalizations.of(context);
    final phoneText =
        _phoneController.text.replaceAll(RegExp(r'\s+'), '').trim();
    if (phoneText.length != 10 || !RegExp(r'^\d{10}$').hasMatch(phoneText)) {
      setState(() {
        _localError = 'Please enter a valid 10-digit phone number';
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
          _showMessage('OTP sent successfully');
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
          _showMessage('Phone number verified successfully');
          context.go('/home');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Temporarily disable localization to test rendering
    // final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final displayError = authState.error ?? _localError;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: _DottedPatternBackground()),
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  16,
                  24,
                  viewInsets + 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: size.height - 32,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          _HeaderSection(),
                          const SizedBox(height: 32),
                          _LoginCard(
                            isLoading: isLoading,
                            phoneController: _phoneController,
                            errorText: displayError,
                            isPhoneTab: _isPhoneTab,
                            onTabChange: (isPhone) {
                              setState(() {
                                _isPhoneTab = isPhone;
                              });
                            },
                            onGoogleTap: _handleGoogleSignIn,
                            onOtpTap: _handleOtpFlow,
                            onEmailTap: () => context.push('/email-auth'),
                          ),
                          const Spacer(),
                          _FooterSection(
                            termsRecognizer: _termsRecognizer,
                            privacyRecognizer: _privacyRecognizer,
                            legalDisclaimerRecognizer: _legalDisclaimerRecognizer,
                          ),
                        ],
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
                child: _LoadingMessage(message: 'Authenticating...'),
              ),
            ),
        ],
      ),
    );
  }
}

class _DottedPatternBackground extends StatelessWidget {
  const _DottedPatternBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
      ),
      child: CustomPaint(
        painter: _DottedPatternPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _DottedPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final dotSpacing = 24.0;
    final dotRadius = 1.5;

    for (double x = 0; x < size.width; x += dotSpacing) {
      for (double y = 0; y < size.height; y += dotSpacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'JusLegal',
            style: GoogleFonts.notoSans(
              color: AppColors.primary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.outline,
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.help_outline_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  final bool isLoading;
  final TextEditingController phoneController;
  final String? errorText;
  final bool isPhoneTab;
  final Function(bool) onTabChange;
  final Future<void> Function() onGoogleTap;
  final Future<void> Function() onOtpTap;
  final VoidCallback onEmailTap;

  const _LoginCard({
    required this.isLoading,
    required this.phoneController,
    required this.errorText,
    required this.isPhoneTab,
    required this.onTabChange,
    required this.onGoogleTap,
    required this.onOtpTap,
    required this.onEmailTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo/Brand
          Text(
            'JusLegal',
            style: GoogleFonts.notoSans(
              color: AppColors.primary,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          
          // Heading
          Text(
            'Secure Access',
            style: GoogleFonts.notoSans(
              color: AppColors.onSurface,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            'Sign in to continue your legal journey.',
            style: GoogleFonts.notoSans(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 24),
          
          // Tabs
          _TabSelector(
            isPhoneTab: isPhoneTab,
            onTabChange: onTabChange,
          ),
          const SizedBox(height: 24),
          
          if (isPhoneTab) ...[
            // Phone input
            _PhoneInputSection(
              phoneController: phoneController,
              isLoading: isLoading,
              errorText: errorText,
              onOtpTap: onOtpTap,
            ),
          ] else ...[
            // Email input (placeholder for now)
            _EmailInputSection(
              onEmailTap: onEmailTap,
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Separator
          _Separator(),
          const SizedBox(height: 24),
          
          // Google button
          _GoogleButton(
            onTap: isLoading ? null : onGoogleTap,
          ),
          const SizedBox(height: 24),
          
          // Create account link
          _CreateAccountLink(),
          const SizedBox(height: 16),
          
          // Disclaimer
          _Disclaimer(),
        ],
      ),
    );
  }
}

class _TabSelector extends StatelessWidget {
  final bool isPhoneTab;
  final Function(bool) onTabChange;

  const _TabSelector({
    required this.isPhoneTab,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChange(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isPhoneTab ? AppColors.surfaceContainerLowest : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusM - 2),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Phone',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSans(
                    color: isPhoneTab ? AppColors.primary : AppColors.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: isPhoneTab ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChange(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: !isPhoneTab ? AppColors.surfaceContainerLowest : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusM - 2),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Email',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSans(
                    color: !isPhoneTab ? AppColors.primary : AppColors.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: !isPhoneTab ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneInputSection extends StatelessWidget {
  final TextEditingController phoneController;
  final bool isLoading;
  final String? errorText;
  final Future<void> Function() onOtpTap;

  const _PhoneInputSection({
    required this.phoneController,
    required this.isLoading,
    required this.errorText,
    required this.onOtpTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile Number',
          style: GoogleFonts.notoSans(
            color: AppColors.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          enabled: !isLoading,
          maxLength: 10,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          style: GoogleFonts.notoSans(
            color: AppColors.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: 'Enter 10-digit number',
            hintStyle: GoogleFonts.notoSans(
              color: AppColors.onSurfaceVariant,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            prefixText: '+91 ',
            prefixStyle: GoogleFonts.notoSans(
              color: AppColors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              borderSide: const BorderSide(
                color: AppColors.outline,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              borderSide: const BorderSide(
                color: AppColors.error,
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: GoogleFonts.notoSans(
              color: AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: isLoading ? null : onOtpTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Send OTP',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmailInputSection extends StatelessWidget {
  final VoidCallback onEmailTap;

  const _EmailInputSection({
    required this.onEmailTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: GoogleFonts.notoSans(
            color: AppColors.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          enabled: false,
          style: GoogleFonts.notoSans(
            color: AppColors.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: 'Enter your email',
            hintStyle: GoogleFonts.notoSans(
              color: AppColors.onSurfaceVariant,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              borderSide: const BorderSide(
                color: AppColors.outline,
                width: 1,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              borderSide: const BorderSide(
                color: AppColors.outline,
                width: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: onEmailTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
            ),
            child: Text(
              'Continue with Email',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: AppColors.outlineVariant,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Or continue with',
            style: GoogleFonts.notoSans(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: AppColors.outlineVariant,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _GoogleButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surfaceContainerLowest,
          foregroundColor: AppColors.onSurface,
          side: const BorderSide(
            color: AppColors.outline,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google Logo
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://www.google.com/favicon.ico'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Continue with Google',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateAccountLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.notoSans(
          color: AppColors.onSurfaceVariant,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        children: [
          const TextSpan(text: 'New to JusLegal? '),
          TextSpan(
            text: 'Create an account',
            style: GoogleFonts.notoSans(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Informational only, not an attorney substitute.',
      textAlign: TextAlign.center,
      style: GoogleFonts.notoSans(
        color: AppColors.onSurfaceVariant,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

class _FooterSection extends StatelessWidget {
  final TapGestureRecognizer termsRecognizer;
  final TapGestureRecognizer privacyRecognizer;
  final TapGestureRecognizer legalDisclaimerRecognizer;

  const _FooterSection({
    required this.termsRecognizer,
    required this.privacyRecognizer,
    required this.legalDisclaimerRecognizer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const Divider(
            color: AppColors.outlineVariant,
            thickness: 1,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'JusLegal © 2024 JusLegal. Justice for all, grounded in ethics.',
                  style: GoogleFonts.notoSans(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  _FooterLink(
                    text: 'Privacy Policy',
                    recognizer: privacyRecognizer,
                  ),
                  const SizedBox(width: 16),
                  _FooterLink(
                    text: 'Terms of Service',
                    recognizer: termsRecognizer,
                  ),
                  const SizedBox(width: 16),
                  _FooterLink(
                    text: 'Legal Disclaimer',
                    recognizer: legalDisclaimerRecognizer,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final TapGestureRecognizer recognizer;

  const _FooterLink({
    required this.text,
    required this.recognizer,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: recognizer.onTap,
      child: Text(
        text,
        style: GoogleFonts.notoSans(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
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
            style: GoogleFonts.notoSans(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
