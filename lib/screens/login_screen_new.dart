import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:juslegal/core/core.dart';
import '../services/auth_handler.dart';
import '../widgets/loading_widget.dart';

enum AuthStep { initial, emailForm, phoneForm }

const _background = Color(0xFFEAF8E6);
const _forest = Color(0xFF1B4D3E);
const _green = Color(0xFF2D6A4F);

class LoginScreenNew extends ConsumerStatefulWidget {
  const LoginScreenNew({super.key});
  @override
  ConsumerState<LoginScreenNew> createState() => _LoginScreenNewState();
}

class _LoginScreenNewState extends ConsumerState<LoginScreenNew>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TapGestureRecognizer _terms;
  late final TapGestureRecognizer _privacy;
  late final TapGestureRecognizer _legal;
  AuthStep _step = AuthStep.initial;
  String? _error;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _terms = TapGestureRecognizer()..onTap = _openTerms;
    _privacy = TapGestureRecognizer()..onTap = _openPrivacy;
    _legal = TapGestureRecognizer()..onTap = () => context.push('/legal-terms');
    _entrance = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650))
      ..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _terms.dispose();
    _privacy.dispose();
    _legal.dispose();
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

  void _message(String value) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(value)));

  void _changeStep(AuthStep step) => setState(() {
        _error = null;
        _step = step;
      });

  Future<void> _google() async {
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
      if (mounted) context.go('/home');
    } catch (e) {
      if (!mounted) return;
      final message = ref.read(authProvider).error ?? e.toString();
      setState(() => _error = message);
      _message(message);
    }
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.replaceAll(RegExp(r'\s+'), '').trim();
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      setState(() => _error = 'Please enter a valid 10-digit phone number');
      return;
    }
    setState(() => _error = null);
    await ref.read(authProvider.notifier).verifyPhone(
      '+91$phone',
      (id) {
        if (!mounted) return;
        _message('OTP sent successfully');
        context
            .push('/otp', extra: {'verificationId': id, 'phoneNumber': phone});
      },
      (error) {
        if (!mounted) return;
        setState(() => _error = error);
        _message(error);
      },
      (_) {
        if (!mounted) return;
        _message('Phone number verified successfully');
        context.go('/home');
      },
    );
  }

  void _continueEmail() {
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
        .hasMatch(_emailController.text.trim())) {
      setState(() => _error = 'Please enter a valid email address');
      return;
    }
    setState(() => _error = null);
    context.push('/email-auth');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final animation =
        CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic);
    return Scaffold(
      backgroundColor: _background,
      resizeToAvoidBottomInset: true,
      body: Stack(children: [
        const Positioned.fill(child: _DottedBackground()),
        SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                24, 16, 24, MediaQuery.viewInsetsOf(context).bottom + 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, .08), end: Offset.zero)
                        .animate(animation),
                    child: Column(children: [
                      const _Header(),
                      const SizedBox(height: 32),
                      _LoginCard(
                        step: _step,
                        isLoading: auth.isLoading,
                        error: auth.error ?? _error,
                        phoneController: _phoneController,
                        emailController: _emailController,
                        onStep: _changeStep,
                        onGoogle: _google,
                        onOtp: _sendOtp,
                        onEmail: _continueEmail,
                        onCreateAccount: () => context.push('/email-auth'),
                      ),
                      const SizedBox(height: 32),
                      _Footer(terms: _terms, privacy: _privacy, legal: _legal),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (auth.isLoading)
          Positioned.fill(
              child: ColoredBox(
                  color: Colors.white.withValues(alpha: .72),
                  child: const _LoadingMessage())),
      ]),
    );
  }
}

class _DottedBackground extends StatelessWidget {
  const _DottedBackground();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _DottedPainter(), size: Size.infinite);
}

class _DottedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _green.withValues(alpha: .08);
    for (var x = 0.0; x < size.width; x += 24) {
      for (var y = 0.0; y < size.height; y += 24) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('JusLegal', style: _style(_forest, 24, FontWeight.w700)),
        const Tooltip(
            message: 'Help',
            child: Icon(Icons.help_outline_rounded, color: _forest)),
      ]);
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.step,
    required this.isLoading,
    required this.error,
    required this.phoneController,
    required this.emailController,
    required this.onStep,
    required this.onGoogle,
    required this.onOtp,
    required this.onEmail,
    required this.onCreateAccount,
  });
  final AuthStep step;
  final bool isLoading;
  final String? error;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final ValueChanged<AuthStep> onStep;
  final Future<void> Function() onGoogle;
  final Future<void> Function() onOtp;
  final VoidCallback onEmail;
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            boxShadow: const [
              BoxShadow(
                  color: AppColors.shadow, blurRadius: 24, offset: Offset(0, 8))
            ]),
        child: Column(children: [
          Text('Secure Access',
              style: _style(AppColors.onSurface, 28, FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Sign in to continue your legal journey.',
              textAlign: TextAlign.center, style: _style(_green, 14)),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(.04, 0), end: Offset.zero)
                        .animate(animation),
                    child: child)),
            child: _stepContent(),
          ),
          const SizedBox(height: 20),
          _CreateAccount(onTap: isLoading ? null : onCreateAccount),
          const SizedBox(height: 12),
          Text('Informational only, not an attorney substitute.',
              textAlign: TextAlign.center,
              style: _style(
                  _green, 11, FontWeight.w400, 1.2, null, FontStyle.italic)),
        ]),
      );

  Widget _stepContent() {
    switch (step) {
      case AuthStep.initial:
        return _Options(
            key: const ValueKey(AuthStep.initial),
            isLoading: isLoading,
            onEmail: () => onStep(AuthStep.emailForm),
            onPhone: () => onStep(AuthStep.phoneForm),
            onGoogle: onGoogle);
      case AuthStep.emailForm:
        return _EmailForm(
            key: const ValueKey(AuthStep.emailForm),
            controller: emailController,
            isLoading: isLoading,
            error: error,
            onBack: () => onStep(AuthStep.initial),
            onSubmit: onEmail);
      case AuthStep.phoneForm:
        return _PhoneForm(
            key: const ValueKey(AuthStep.phoneForm),
            controller: phoneController,
            isLoading: isLoading,
            error: error,
            onBack: () => onStep(AuthStep.initial),
            onSubmit: onOtp);
    }
  }
}

class _Options extends StatelessWidget {
  const _Options(
      {super.key,
      required this.isLoading,
      required this.onEmail,
      required this.onPhone,
      required this.onGoogle});
  final bool isLoading;
  final VoidCallback onEmail;
  final VoidCallback onPhone;
  final Future<void> Function() onGoogle;
  @override
  Widget build(BuildContext context) => Column(children: [
        _PrimaryButton(
            label: 'Continue with Email',
            icon: Icons.email_outlined,
            onPressed: isLoading ? null : onEmail),
        const SizedBox(height: 12),
        _SecondaryButton(
            label: 'Continue with Mobile Number',
            icon: Icons.phone_outlined,
            onPressed: isLoading ? null : onPhone),
        const SizedBox(height: 24),
        const _Separator(),
        const SizedBox(height: 24),
        _SecondaryButton(
            label: 'Continue with Google',
            leading: Text('G', style: _style(_forest, 18, FontWeight.w700)),
            onPressed: isLoading ? null : onGoogle),
      ]);
}

class _EmailForm extends StatelessWidget {
  const _EmailForm(
      {super.key,
      required this.controller,
      required this.isLoading,
      required this.error,
      required this.onBack,
      required this.onSubmit});
  final TextEditingController controller;
  final bool isLoading;
  final String? error;
  final VoidCallback onBack;
  final VoidCallback onSubmit;
  @override
  Widget build(BuildContext context) => _FormShell(
      title: 'Continue with email',
      onBack: onBack,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Label('Email Address'),
        const SizedBox(height: 8),
        TextField(
            controller: controller,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            onSubmitted: (_) => onSubmit(),
            style: _style(AppColors.onSurface, 16),
            decoration: _input('Enter your email', icon: Icons.email_outlined)),
        _Error(error),
        const SizedBox(height: 16),
        _PrimaryButton(
            label: 'Continue', onPressed: isLoading ? null : onSubmit),
      ]));
}

class _PhoneForm extends StatelessWidget {
  const _PhoneForm(
      {super.key,
      required this.controller,
      required this.isLoading,
      required this.error,
      required this.onBack,
      required this.onSubmit});
  final TextEditingController controller;
  final bool isLoading;
  final String? error;
  final VoidCallback onBack;
  final Future<void> Function() onSubmit;
  @override
  Widget build(BuildContext context) => _FormShell(
      title: 'Continue with mobile',
      onBack: onBack,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Label('Phone Number'),
        const SizedBox(height: 8),
        TextField(
            controller: controller,
            enabled: !isLoading,
            keyboardType: TextInputType.phone,
            autofillHints: const [AutofillHints.telephoneNumber],
            maxLength: 10,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10)
            ],
            onSubmitted: (_) => onSubmit(),
            style: _style(AppColors.onSurface, 16),
            decoration: _input('Enter 10-digit number', prefix: '+91 ')
                .copyWith(counterText: '')),
        _Error(error),
        const SizedBox(height: 16),
        _PrimaryButton(
            label: 'Send OTP',
            icon: Icons.arrow_forward,
            onPressed: isLoading ? null : onSubmit),
      ]));
}

class _FormShell extends StatelessWidget {
  const _FormShell(
      {required this.title, required this.onBack, required this.child});
  final String title;
  final VoidCallback onBack;
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        IconButton(
            tooltip: 'Back to sign-in options',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: _forest,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48)),
        const SizedBox(height: 8),
        Text(title, style: _style(_forest, 20, FontWeight.w700)),
        const SizedBox(height: 20),
        child,
      ]);
}

class _Label extends StatelessWidget {
  const _Label(this.value);
  final String value;
  @override
  Widget build(BuildContext context) =>
      Text(value, style: _style(AppColors.onSurface, 14, FontWeight.w600));
}

class _Error extends StatelessWidget {
  const _Error(this.value);
  final String? value;
  @override
  Widget build(BuildContext context) => value == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(value!,
              style: _style(AppColors.error, 12, FontWeight.w500)));
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton(
      {required this.label, this.icon, required this.onPressed});
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 19),
        label: Text(label,
            textAlign: TextAlign.center,
            style: _style(Colors.white, 16, FontWeight.w600)),
        style: ElevatedButton.styleFrom(
            backgroundColor: _forest,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.surfaceContainerHigh,
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM))),
      ));
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton(
      {required this.label, this.icon, this.leading, required this.onPressed});
  final String label;
  final IconData? icon;
  final Widget? leading;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
            foregroundColor: _forest,
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            side: const BorderSide(color: _green),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (leading != null)
            leading!
          else if (icon != null)
            Icon(icon, size: 19),
          if (leading != null || icon != null) const SizedBox(width: 10),
          Flexible(
              child: Text(label,
                  textAlign: TextAlign.center,
                  style: _style(_forest, 16, FontWeight.w600))),
        ]),
      ));
}

class _Separator extends StatelessWidget {
  const _Separator();
  @override
  Widget build(BuildContext context) => Row(children: [
        const Expanded(child: Divider(color: AppColors.outlineVariant)),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('Or continue with', style: _style(_green, 12))),
        const Expanded(child: Divider(color: AppColors.outlineVariant))
      ]);
}

class _CreateAccount extends StatelessWidget {
  const _CreateAccount({required this.onTap});
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12)),
      child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(style: _style(_green, 14), children: [
            const TextSpan(text: 'New to JusLegal? '),
            TextSpan(
                text: 'Create an account',
                style: _style(_forest, 14, FontWeight.w700, 1.2,
                    TextDecoration.underline))
          ])));
}

class _Footer extends StatelessWidget {
  const _Footer(
      {required this.terms, required this.privacy, required this.legal});
  final TapGestureRecognizer terms;
  final TapGestureRecognizer privacy;
  final TapGestureRecognizer legal;
  @override
  Widget build(BuildContext context) => Column(children: [
        const Divider(color: AppColors.outlineVariant),
        const SizedBox(height: 16),
        Text('© 2024 JusLegal. Justice for all, grounded in ethics.',
            textAlign: TextAlign.center, style: _style(_green, 11)),
        const SizedBox(height: 10),
        Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              _FooterLink('Privacy Policy', privacy),
              _FooterLink('Terms of Service', terms),
              _FooterLink('Legal Disclaimer', legal)
            ]),
      ]);
}

class _FooterLink extends StatelessWidget {
  const _FooterLink(this.text, this.recognizer);
  final String text;
  final TapGestureRecognizer recognizer;
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: recognizer.onTap,
      child: Text(text,
          style: _style(
              _forest, 11, FontWeight.w600, 1.2, TextDecoration.underline)));
}

class _LoadingMessage extends StatelessWidget {
  const _LoadingMessage();
  @override
  Widget build(BuildContext context) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const LoadingWidget(size: 40),
        const SizedBox(height: 16),
        Text('Authenticating...',
            style: _style(AppColors.textPrimary, 14, FontWeight.w600))
      ]));
}

TextStyle _style(Color color, double size,
        [FontWeight weight = FontWeight.w400,
        double height = 1.2,
        TextDecoration? decoration,
        FontStyle? fontStyle]) =>
    GoogleFonts.notoSans(
        color: color,
        fontSize: size,
        fontWeight: weight,
        height: height,
        decoration: decoration,
        fontStyle: fontStyle);

InputDecoration _input(String hint, {IconData? icon, String? prefix}) =>
    InputDecoration(
      hintText: hint,
      hintStyle: _style(AppColors.onSurfaceVariant, 16),
      prefixIcon: icon == null ? null : Icon(icon, color: _green),
      prefixText: prefix,
      prefixStyle: _style(_forest, 16, FontWeight.w600),
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          borderSide: const BorderSide(color: AppColors.outline)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          borderSide: const BorderSide(color: _green, width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          borderSide: const BorderSide(color: AppColors.error)),
    );
