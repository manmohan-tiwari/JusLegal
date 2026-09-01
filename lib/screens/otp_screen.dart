import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:juslegal/l10n/gen/app_localizations.dart';

import 'package:juslegal/core/core.dart';
import '../services/auth_handler.dart';
import '../widgets/loading_widget.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  late final List<FocusNode> _focusNodes;
  late final List<TextEditingController> _controllers;

  Timer? _timer;
  int _secondsRemaining = 30;
  String? _localError;
  bool _isAutoSubmitted = false;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(6, (index) => FocusNode());
    _controllers = List.generate(6, (index) => TextEditingController());
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 30;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String get _otp {
    return _controllers.map((c) => c.text).join();
  }

  void _checkAndSubmit() {
    final otpText = _otp;
    if (otpText.length == 6 && !_isAutoSubmitted) {
      _isAutoSubmitted = true;
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    final l10n = AppLocalizations.of(context);
    final otpText = _otp;
    if (otpText.length != 6) {
      _isAutoSubmitted = false;
      setState(() {
        _localError = l10n.enterOtpDigits;
      });
      return;
    }
    setState(() {
      _localError = null;
    });

    final goRouter = GoRouter.of(context);
    try {
      await ref.read(authProvider.notifier).verifyOTP(
            widget.verificationId,
            otpText,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.phoneNumberVerifiedSuccessfully)),
      );
      goRouter.go('/home');
    } catch (error) {
      if (!mounted) return;
      final message = ref.read(authProvider).error ?? error.toString();
      setState(() {
        _isAutoSubmitted = false;
        _localError = message;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _resendOtp() async {
    if (_secondsRemaining > 0) return;

    setState(() {
      _localError = null;
      _isAutoSubmitted = false;
    });

    final fullPhoneNumber = widget.phoneNumber.startsWith('+')
        ? widget.phoneNumber
        : "+91${widget.phoneNumber}";

    await ref.read(authProvider.notifier).verifyPhone(
      fullPhoneNumber,
      (newVerificationId) {
        // Verification ID refreshed
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(AppLocalizations.of(context).otpResentSuccessfully)),
          );
          _startTimer();
        }
      },
      (error) {
        if (mounted) {
          setState(() {
            _localError = error;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
      },
      (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phone number verified successfully')),
          );
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.verifyYourNumber,
                    style: GoogleFonts.merriweather(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.otpSentTo(
                        widget.phoneNumber.replaceFirst('+91', '').trim()),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // OTP Input Fields
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final fields = <Widget>[];
                      for (var index = 0; index < 6; index++) {
                        fields.add(
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                enabled: !isLoading,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(1),
                                ],
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: const InputDecoration(
                                  counterText: "",
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    if (index < 5) {
                                      _focusNodes[index + 1].requestFocus();
                                    }
                                  } else {
                                    if (index > 0) {
                                      _focusNodes[index - 1].requestFocus();
                                    }
                                  }
                                  _checkAndSubmit();
                                },
                              ),
                            ),
                          ),
                        );
                        if (index < 5) {
                          fields.add(const SizedBox(width: 8));
                        }
                      }
                      return Row(children: fields);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Verify OTP button
                  ElevatedButton(
                    onPressed: isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(l10n.verifyOtp),
                  ),
                  const SizedBox(height: 16),

                  // Resend countdown or button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.didntReceiveOtp,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      _secondsRemaining > 0
                          ? Text(
                              l10n.resendIn(
                                '0:${_secondsRemaining.toString().padLeft(2, '0')}',
                              ),
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : TextButton(
                              onPressed: isLoading ? null : _resendOtp,
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.legalGold,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                minimumSize: const Size(64, 48),
                              ),
                              child: Text(l10n.resend),
                            ),
                    ],
                  ),

                  if (displayError != null) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        displayError,
                        style: const TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.white70,
                  child: const LoadingMessageWidget(
                    message: 'Verifying OTP...',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class LoadingMessageWidget extends StatelessWidget {
  final String message;

  const LoadingMessageWidget({
    super.key,
    required this.message,
  });

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
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
