import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:juslegal/core/core.dart';
import 'package:juslegal/core/router/otp_route_params.dart';
import 'package:juslegal/core/utils/phone_number_validator.dart';
import 'package:juslegal/services/auth_handler.dart';
import 'package:juslegal/services/user_profile_service.dart';

String? legalNameError(String? value) =>
    RegExp(r"^[A-Za-z][A-Za-z '\-]{1,98}$").hasMatch(value?.trim() ?? '')
        ? null
        : 'Please enter a valid legal name';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child, this.showBack = true});
  final Widget child;
  final bool showBack;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: showBack
            ? AppBar(backgroundColor: Colors.transparent, elevation: 0)
            : null,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: child,
              ),
            ),
          ),
        ),
      );
}

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with TickerProviderStateMixin {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late final AnimationController _entrance;
  late final AnimationController _scales;
  bool _acceptedTerms = false;
  bool _hidePassword = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
    _scales = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entrance.dispose();
    _scales.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (!_acceptedTerms) {
      _snack(context, 'Please accept the Terms of Service to continue.');
      return;
    }
    setState(() => _loading = true);
    try {
      final email = _email.text.trim().toLowerCase();
      if (await UserProfileService().emailExists(email)) {
        throw Exception(
            'This email is already registered. Try logging in instead.');
      }
      final credential =
          await ref.read(authProvider.notifier).registerWithEmail(
                email,
                _password.text,
              );
      await UserProfileService().saveProfile(
        credential.user!,
        legalName: _name.text.trim(),
        provider: 'email',
      );
      if (mounted) context.go('/email-verification', extra: email);
    } catch (error) {
      if (mounted) _snack(context, friendlyError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF5FAF7),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 820;
              return isWide
                  ? Row(children: [
                      Expanded(flex: 11, child: _visualPanel()),
                      Expanded(flex: 9, child: _formPanel())
                    ])
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(children: [
                        SizedBox(height: 310, child: _visualPanel()),
                        const SizedBox(height: 24),
                        _formPanel(),
                      ]),
                    );
            },
          ),
        ),
      );

  Widget _visualPanel() => Container(
        constraints: const BoxConstraints(minHeight: 640),
        padding: const EdgeInsets.all(48),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7CB342), Color(0xFF558B2F)],
          ),
        ),
        child: AnimatedBuilder(
          animation: _entrance,
          builder: (context, child) => Opacity(
            opacity: _entrance.value,
            child: Transform.translate(
              offset: Offset(-24 * (1 - _entrance.value), 0),
              child: child,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Center(
                child: AnimatedBuilder(
                  animation: _scales,
                  builder: (context, _) => CustomPaint(
                    size: const Size(270, 220),
                    painter: _ScalesPainter(_scales.value),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text('JusLegal',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2)),
              const SizedBox(height: 8),
              const Text('Expert Legal Guidance',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w400)),
              const SizedBox(height: 28),
              ...[
                'Instant Legal Answers',
                'Case References & Laws',
                '100% Private & Secure',
              ].map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(item,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: .92),
                              fontSize: 15)),
                    ]),
                  )),
              const Spacer(),
            ],
          ),
        ),
      );

  Widget _formPanel() => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 470),
          child: Padding(
            padding: const EdgeInsets.all(36),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Get Legal Clarity',
                      style: TextStyle(
                          color: Color(0xFF2D3B2D),
                          fontSize: 32,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text('Sign up to start exploring your rights',
                      style: TextStyle(color: Color(0xFF7A8478), fontSize: 16)),
                  const SizedBox(height: 34),
                  _input(_name, 'Full name', Icons.person_outline,
                      validator: legalNameError),
                  const SizedBox(height: 16),
                  _input(_email, 'Email address', Icons.mail_outline,
                      keyboard: TextInputType.emailAddress,
                      validator: (value) =>
                          EmailValidator.isValid(value?.trim() ?? '')
                              ? null
                              : 'Enter a valid email address'),
                  const SizedBox(height: 16),
                  _input(_password, 'Password', Icons.lock_outline,
                      obscure: _hidePassword,
                      suffix: IconButton(
                          icon: Icon(_hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword)),
                      validator: (value) => PasswordValidator.isStrong(
                              value ?? '')
                          ? null
                          : 'Use 8+ characters with upper, lower, number, and symbol'),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: _acceptedTerms,
                    onChanged: (value) =>
                        setState(() => _acceptedTerms = value ?? false),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: const Color(0xFF7CB342),
                    title: const Text('I agree to the Terms of Service',
                        style:
                            TextStyle(color: Color(0xFF7A8478), fontSize: 13)),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF7CB342), Color(0xFF558B2F)]),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x337CB342),
                              blurRadius: 14,
                              offset: Offset(0, 6))
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Create account',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => context.go('/home'),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text(
                        'Explore App as Guest',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF558B2F),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                      child: Wrap(alignment: WrapAlignment.center, children: [
                    const Text('Already have an account? ',
                        style: TextStyle(color: Color(0xFF7A8478))),
                    TextButton(
                        onPressed: () => context.push('/login'),
                        child: const Text('Log in'))
                  ])),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _input(TextEditingController controller, String label, IconData icon,
          {bool obscure = false,
          Widget? suffix,
          TextInputType? keyboard,
          String? Function(String?)? validator}) =>
      TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        validator: validator,
        decoration: InputDecoration(
            labelText: label, prefixIcon: Icon(icon), suffixIcon: suffix),
      );
}

class _ScalesPainter extends CustomPainter {
  _ScalesPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final glow = Paint()
      ..shader = RadialGradient(
              colors: [Colors.white.withValues(alpha: .3), Colors.transparent])
          .createShader(Rect.fromCircle(center: center, radius: 105));
    canvas.drawCircle(center, 105, glow);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate((progress - .5) * .42);
    final stroke = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = Colors.white;
    canvas.drawLine(const Offset(0, -78), const Offset(0, 70), stroke);
    canvas.drawLine(const Offset(-48, -35), const Offset(48, -35), stroke);
    canvas.drawCircle(const Offset(0, -84), 8, fill);
    canvas.drawPath(
        Path()
          ..moveTo(-16, 70)
          ..lineTo(16, 70)
          ..lineTo(8, 56)
          ..lineTo(-8, 56)
          ..close(),
        fill);
    final left = -48.0 + (progress - .5) * 12;
    final right = 48.0 - (progress - .5) * 12;
    canvas.drawLine(Offset(left, -35), Offset(left - 22, 15), stroke);
    canvas.drawLine(Offset(left, -35), Offset(left + 22, 15), stroke);
    canvas.drawLine(Offset(right, -35), Offset(right - 22, 15), stroke);
    canvas.drawLine(Offset(right, -35), Offset(right + 22, 15), stroke);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(left, 21), width: 78, height: 18),
        stroke);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(right, 21), width: 78, height: 18),
        stroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScalesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class SignUpMethodScreen extends ConsumerWidget {
  const SignUpMethodScreen({super.key});
  Future<void> _google(BuildContext context, WidgetRef ref) async {
    try {
      final credential =
          await ref.read(authProvider.notifier).signInWithGoogle();
      final user = credential.user!;
      final profile = UserProfileService();
      if (!await profile.exists(user.uid)) {
        final name = user.displayName?.trim() ?? '';
        if (legalNameError(name) != null) {
          if (context.mounted) context.push('/confirm-name', extra: user);
          return;
        }
        await profile.saveProfile(user, legalName: name, provider: 'google');
      }
      if (context.mounted) context.go('/home');
    } catch (e) {
      if (context.mounted) _snack(context, friendlyError(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => AuthScaffold(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Create an account',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Choose how you would like to continue.'),
        const SizedBox(height: 32),
        OutlinedButton.icon(
            onPressed: () => _google(context, ref),
            icon: const Icon(Icons.g_mobiledata, size: 28),
            label: const Text('Continue with Google')),
        const SizedBox(height: 12),
        OutlinedButton.icon(
            onPressed: () => context.push('/mobile-signup'),
            icon: const Icon(Icons.phone_outlined),
            label: const Text('Continue with Mobile')),
        const SizedBox(height: 12),
        OutlinedButton.icon(
            onPressed: () => context.push('/email-signup'),
            icon: const Icon(Icons.email_outlined),
            label: const Text('Continue with Email')),
      ]));
}

class EmailSignupScreen extends ConsumerStatefulWidget {
  const EmailSignupScreen({super.key});
  @override
  ConsumerState<EmailSignupScreen> createState() => _EmailSignupScreenState();
}

class _EmailSignupScreenState extends ConsumerState<EmailSignupScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _hide = true;
  bool _loading = false;
  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final email = _email.text.trim().toLowerCase();
      if (await UserProfileService().emailExists(email)) {
        throw Exception(
            'This email is already registered. Try logging in instead.');
      }
      final credential = await ref
          .read(authProvider.notifier)
          .registerWithEmail(email, _password.text);
      await UserProfileService().saveProfile(credential.user!,
          legalName: _name.text, provider: 'email');
      if (mounted) context.go('/email-verification', extra: email);
    } catch (e) {
      if (mounted) _snack(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
      child: Form(
          key: _form,
          onChanged: () => setState(() {}),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Create Your Account',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 28),
            _field(_name, 'Legal Name', 'Enter your full legal name',
                validator: legalNameError,
                textCapitalization: TextCapitalization.words),
            const SizedBox(height: 14),
            _field(_email, 'Email Address', 'name@example.com',
                keyboard: TextInputType.emailAddress,
                validator: (v) => EmailValidator.isValid(v?.trim() ?? '')
                    ? null
                    : 'Please enter a valid email address'),
            const SizedBox(height: 14),
            _field(_password, 'Password', 'Create a strong password',
                obscure: _hide,
                suffix: IconButton(
                    icon: Icon(_hide
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _hide = !_hide)),
                validator: (v) => PasswordValidator.isStrong(v ?? '')
                    ? null
                    : 'Password must be 8+ chars with uppercase, lowercase, number, and special character'),
            const SizedBox(height: 14),
            _field(_confirm, 'Confirm Password', 'Re-enter your password',
                obscure: _hide,
                validator: (v) =>
                    v == _password.text ? null : 'Passwords do not match'),
            const SizedBox(height: 26),
            SizedBox(
                height: 52,
                child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text('Create Account'))),
          ])));
}

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key, required this.email});
  final String email;
  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  Timer? _poll;
  Timer? _countdown;
  int _seconds = 0;
  int _resends = 0;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    _poll =
        Timer.periodic(const Duration(seconds: 3), (_) => _check(silent: true));
  }

  @override
  void dispose() {
    _poll?.cancel();
    _countdown?.cancel();
    super.dispose();
  }

  Future<void> _check({bool silent = false}) async {
    if (_loading) return;
    if (!silent) setState(() => _loading = true);
    try {
      final verified =
          await ref.read(authProvider.notifier).checkEmailVerification();
      if (!mounted) return;
      if (verified) {
        await UserProfileService().markEmailVerified(
          FirebaseAuth.instance.currentUser!.uid,
        );
        if (!mounted) return;
        _snack(context, 'Email verified successfully.', success: true);
        await Future<void>.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        context.go('/home');
      } else if (!silent) {
        _snack(context, 'Email not verified yet. Please check your inbox.');
      }
    } catch (_) {
    } finally {
      if (mounted && !silent) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    if (_seconds > 0 || _resends >= 3) return;
    setState(() {
      _loading = true;
      _resends++;
      _seconds = 30;
    });
    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _seconds == 0) {
        t.cancel();
        return;
      }
      setState(() => _seconds--);
    });
    try {
      await ref.read(authProvider.notifier).sendEmailVerification();
      if (mounted) _snack(context, 'Verification email sent.', success: true);
    } catch (e) {
      if (mounted) _snack(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changeEmail() async {
    final change = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: const Text('Change email?'),
                content:
                    const Text("Are you sure? You'll need to sign up again."),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Change Email'))
                ]));
    if (change == true) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await UserProfileService().delete(user.uid);
        await user.delete();
      }
      if (mounted) context.go('/email-signup');
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: false,
      child: AuthScaffold(
          showBack: false,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Verify Your Email',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text("We've sent a verification link to:"),
            const SizedBox(height: 6),
            Text(
                widget.email.isEmpty
                    ? (FirebaseAuth.instance.currentUser?.email ?? '')
                    : widget.email,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
                'Please click the link in your email to confirm that you have access to this email address.'),
            const SizedBox(height: 28),
            SizedBox(
                height: 52,
                child: ElevatedButton(
                    onPressed: _loading ? null : _check,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text('Check Again'))),
            TextButton(
                onPressed:
                    _loading || _seconds > 0 || _resends >= 3 ? null : _resend,
                child: Text(_resends >= 3
                    ? 'Too many attempts. Try again in 24 hours.'
                    : _seconds > 0
                        ? 'Resend in ${_seconds}s'
                        : 'Resend Email')),
            TextButton(
                onPressed: _loading ? null : _changeEmail,
                child: const Text('Change Email')),
            TextButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text(
                'Explore App as Guest / Skip for now',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF558B2F),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) context.go('/');
              },
              child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            ),
          ])));
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hide = true;
  bool _loading = false;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _emailLogin() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(authProvider.notifier)
          .signInWithEmail(_email.text.trim(), _password.text);
      if (mounted) context.go('/home');
    } on EmailVerificationRequiredException {
      if (mounted) context.go('/email-verification', extra: _email.text.trim());
    } catch (e) {
      if (mounted) _snack(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _google() async {
    setState(() => _loading = true);
    try {
      final c = await ref.read(authProvider.notifier).signInWithGoogle();
      if (!await UserProfileService().exists(c.user!.uid)) {
        throw Exception(
            'No account found. Please sign up or use a different method.');
      }
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) _snack(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
      child: Form(
          key: _form,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Welcome Back',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 28),
            SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                    onPressed: _loading ? null : _google,
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: const Text('Continue with Google'))),
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Row(children: [
                  Expanded(child: Divider()),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('OR')),
                  Expanded(child: Divider())
                ])),
            _field(_email, 'Email Address', 'name@example.com',
                keyboard: TextInputType.emailAddress,
                validator: (v) => EmailValidator.isValid(v?.trim() ?? '')
                    ? null
                    : 'Please enter a valid email address'),
            const SizedBox(height: 14),
            _field(_password, 'Password', 'Enter your password',
                obscure: _hide,
                suffix: IconButton(
                    icon: Icon(_hide
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _hide = !_hide)),
                validator: (v) =>
                    (v ?? '').isEmpty ? 'Please enter your password' : null),
            Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text('Forgot Password?'))),
            SizedBox(
                height: 52,
                child: ElevatedButton(
                    onPressed: _loading ? null : _emailLogin,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text('Login'))),
            TextButton(
                onPressed: () => context.push('/mobile-login'),
                child: const Text('Login with Mobile')),
            TextButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text(
                'Explore App as Guest',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF558B2F),
                ),
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Don't have an account?"),
              TextButton(
                  onPressed: () => context.push('/signup-method'),
                  child: const Text('Sign Up'))
            ])
          ])));
}

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _sent = false;
  bool _loading = false;
  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!EmailValidator.isValid(_email.text)) {
      _snack(context, 'Please enter a valid email address');
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).resetPassword(_email.text.trim());
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) _snack(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(_sent ? 'Check Your Email' : 'Reset Your Password',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text(_sent
            ? "We've sent a password reset link to:\n${_email.text.trim()}\n\nClick the link in the email to reset your password. The link will expire in 1 hour."
            : "Enter the email address associated with your account. We'll send you a link to reset your password."),
        const SizedBox(height: 28),
        if (!_sent) ...[
          _field(_email, 'Email Address', 'name@example.com',
              keyboard: TextInputType.emailAddress),
          const SizedBox(height: 20),
          SizedBox(
              height: 52,
              child: ElevatedButton(
                  onPressed: _loading ? null : _send,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Send Reset Link')))
        ] else ...[
          SizedBox(
              height: 52,
              child: ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Return to Login'))),
          TextButton(
              onPressed: _loading ? null : _send,
              child: const Text("Didn't receive email? Resend")),
          TextButton(
              onPressed: () => setState(() => _sent = false),
              child: const Text('Change Email'))
        ]
      ]));
}

class MobileEntryScreen extends ConsumerStatefulWidget {
  const MobileEntryScreen({super.key, required this.signup});
  final bool signup;
  @override
  ConsumerState<MobileEntryScreen> createState() => _MobileEntryScreenState();
}

class _MobileEntryScreenState extends ConsumerState<MobileEntryScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  bool _loading = false;
  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    final phone = PhoneNumberValidator.normalize(_phone.text);
    setState(() => _loading = true);
    try {
      final profile = UserProfileService();
      final exists = await profile.phoneExists(phone);
      if (widget.signup && exists) {
        throw Exception(
            'This phone number is already registered. Try logging in instead.');
      }
      if (!widget.signup && !exists) {
        throw Exception(
            'No account found with this phone number. Please sign up.');
      }
      await ref.read(authProvider.notifier).verifyPhone(phone, (id) {
        if (mounted) {
          context.push('/otp',
              extra: OtpRouteParams(
                  verificationId: id,
                  phoneNumber: phone,
                  legalName: widget.signup ? _name.text.trim() : null,
                  isSignup: widget.signup));
        }
      }, (m) {
        if (mounted) _snack(context, m);
      }, (credential) async {
        if (widget.signup) {
          await profile.saveProfile(credential.user!,
              legalName: _name.text, provider: 'phone', phoneVerified: true);
        }
        if (mounted) context.go('/home');
      });
    } catch (e) {
      if (mounted) _snack(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
      child: Form(
          key: _form,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(widget.signup ? 'Create Your Account' : 'Login with Mobile',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 28),
            if (widget.signup) ...[
              _field(_name, 'Legal Name', 'Enter your full legal name',
                  validator: legalNameError,
                  textCapitalization: TextCapitalization.words),
              const SizedBox(height: 14)
            ],
            _field(_phone, 'Mobile Number', '+91 Enter mobile number',
                keyboard: TextInputType.phone,
                formatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]'))
                ],
                validator: (v) => PhoneNumberValidator.isValid(v ?? '')
                    ? null
                    : 'Enter a valid 10-digit Indian mobile number'),
            const SizedBox(height: 24),
            SizedBox(
                height: 52,
                child: ElevatedButton(
                    onPressed: _loading ? null : _send,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : Text(widget.signup ? 'Continue' : 'Send OTP'))),
            if (!widget.signup)
              TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Login with Email'))
          ])));
}

class ConfirmNameScreen extends StatefulWidget {
  const ConfirmNameScreen({super.key, required this.user});
  final User user;
  @override
  State<ConfirmNameScreen> createState() => _ConfirmNameScreenState();
}

class _ConfirmNameScreenState extends State<ConfirmNameScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.user.displayName ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await UserProfileService()
          .saveProfile(widget.user, legalName: _name.text, provider: 'google');
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) _snack(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext c) => AuthScaffold(
      child: Form(
          key: _form,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Confirm Your Name',
                style: Theme.of(c)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Please enter the name you use for legal services.'),
            const SizedBox(height: 24),
            _field(_name, 'Legal Name', 'Enter your full legal name',
                validator: legalNameError),
            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Continue'))
          ])));
}

Widget _field(TextEditingController controller, String label, String hint,
        {String? Function(String?)? validator,
        TextInputType? keyboard,
        bool obscure = false,
        Widget? suffix,
        List<TextInputFormatter>? formatters,
        TextCapitalization textCapitalization = TextCapitalization.none}) =>
    TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboard,
        obscureText: obscure,
        inputFormatters: formatters,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
            labelText: label, hintText: hint, suffixIcon: suffix));
void _snack(BuildContext context, String message, {bool success = false}) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: success ? AppTheme.success : AppTheme.error));
String friendlyError(Object error) {
  final text = error.toString().replaceFirst('Exception: ', '');
  if (text.contains('network-request-failed')) {
    return 'No internet connection. Please try again.';
  }
  if (text.contains('too-many-requests')) {
    return 'Too many login attempts. Try again in 24 hours.';
  }
  if (text.contains('wrong-password') || text.contains('invalid-credential')) {
    return 'Incorrect password. Please try again.';
  }
  if (text.contains('user-not-found')) {
    return 'Email not found. Please sign up.';
  }
  if (text.contains('user-disabled')) {
    return 'This account has been disabled. Contact support.';
  }
  return text;
}
