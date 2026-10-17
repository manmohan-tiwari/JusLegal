import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:juslegal/l10n/gen/app_localizations.dart';

import 'package:juslegal/core/core.dart';
import '../services/auth_handler.dart';
import '../services/user_profile_service.dart';
import '../widgets/loading_widget.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final String? legalName;
  final bool isSignup;

  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    this.legalName,
    this.isSignup = false,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const int _otpExpirySeconds = 120;
  
  late final List<FocusNode> _focusNodes;
  late final List<TextEditingController> _controllers;

  Timer? _timer;
  Timer? _autoSubmitTimer;
  int _secondsRemaining = _otpExpirySeconds;
  String? _localError;
  bool _isAutoSubmitted = false;
  bool _isSubmitting = false; // ✅ FIX: Added submission flag
  late String _currentVerificationId;
  int _wrongAttempts = 0;
  int _resendAttempts = 0;

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
    _focusNodes = List.generate(6, (index) => FocusNode());
    _controllers = List.generate(6, (index) => TextEditingController());
    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel(); // ✅ FIX: Always cancel first
    if (!mounted) return;
    
    setState(() {
      _secondsRemaining = _otpExpirySeconds;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        // ✅ FIX: Show expiry message
        if (mounted) {
          setState(() {
            _localError = AppLocalizations.of(context).otpExpired;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _autoSubmitTimer?.cancel();
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

  // ✅ FIX: Improved clear fields with reset option
  void _clearFields({String? error, bool resetAll = false}) {
    _autoSubmitTimer?.cancel();
    _isAutoSubmitted = false;
    _isSubmitting = false;
    
    // Reset all controllers
    for (var controller in _controllers) {
      controller.clear();
    }
    
    // Reset timers if needed
    if (resetAll) {
      _timer?.cancel();
      _secondsRemaining = _otpExpirySeconds;
      _startTimer();
    }
    
    if (mounted) {
      setState(() {
        _localError = error;
      });
      _focusNodes[0].requestFocus();
    }
  }

  // ✅ FIX: Fixed auto-submission with proper flags
  void _checkAndSubmit() {
    final otpText = _otp;
    if (otpText.length == 6 && !_isAutoSubmitted && !_isSubmitting) {
      _autoSubmitTimer?.cancel();
      _autoSubmitTimer = Timer(const Duration(milliseconds: 500), () {
        if (!mounted || _isSubmitting || _isAutoSubmitted) return;
        _isAutoSubmitted = true;
        _verifyOtp();
      });
    }
  }

  // ✅ FIX: Fixed paste functionality with proper field filling
  Future<void> _pasteFromClipboard() async {
    if (_isSubmitting) return;
    
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final text = clipboardData?.text;
    if (text == null || text.trim().isEmpty) return;

    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;

    // Clear all fields first
    for (var controller in _controllers) {
      controller.clear();
    }

    // Fill fields with digits
    final codeLength = digits.length >= 6 ? 6 : digits.length;
    for (var i = 0; i < codeLength; i++) {
      _controllers[i].text = digits[i];
    }

    // Focus on appropriate field
    if (codeLength < 6) {
      _focusNodes[codeLength].requestFocus();
    } else {
      _focusNodes[5].requestFocus();
      // Auto-submit if 6 digits
      _checkAndSubmit();
    }
    
    setState(() {});
  }

  // ✅ FIX: Added proper submission handling
  Future<void> _verifyOtp() async {
    if (_isSubmitting) return; // ✅ Prevent concurrent submissions
    
    final l10n = AppLocalizations.of(context);
    final otpText = _otp;
    
    if (otpText.length != 6) {
      _clearFields(error: l10n.enterOtpDigits);
      return;
    }
    
    setState(() {
      _isSubmitting = true;
      _localError = null;
    });

    if (_secondsRemaining == 0) {
      _clearFields(error: 'OTP has expired. Request a new one.');
      return;
    }
    if (_wrongAttempts >= 3) {
      _clearFields(error: 'Too many attempts. Please request a new OTP.');
      return;
    }
    try {
      final credential = await ref.read(authProvider.notifier).verifyOTP(
            _currentVerificationId,
            otpText,
          );
      if (!mounted) return;
      if (widget.isSignup && widget.legalName != null) {
        await UserProfileService().saveProfile(
          credential.user!, legalName: widget.legalName!, provider: 'phone', phoneVerified: true,
        );
      }
      if (!mounted) return;
      
      // ✅ FIX: Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.phoneNumberVerifiedSuccessfully),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // ✅ FIX: Navigate after a small delay to show success
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) context.go('/home');
      });
      
    } catch (error) {
      if (!mounted) return;
      
      // ✅ FIX: Reset flags for retry
      _wrongAttempts++;
      final message = _wrongAttempts >= 3
          ? 'Too many attempts. Please request a new OTP.'
          : 'Incorrect OTP. Try again. ($_wrongAttempts of 3 attempts)';
      setState(() {
        _localError = message;
        _isSubmitting = false;
        _isAutoSubmitted = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
      
      // ✅ FIX: Clear fields for retry
      _clearFields(error: message);
    }
  }

  // ✅ FIX: Fixed resend with proper cleanup
  Future<void> _resendOtp() async {
    if (_secondsRemaining > 0 || _isSubmitting || _resendAttempts >= 3) return;

    final l10n = AppLocalizations.of(context);
    
    // ✅ FIX: Clear all fields and reset state
    _resendAttempts++;
    _wrongAttempts = 0;
    _clearFields(resetAll: true);

    final fullPhoneNumber = widget.phoneNumber.startsWith('+')
        ? widget.phoneNumber
        : "+91${widget.phoneNumber}";

    try {
      await ref.read(authProvider.notifier).verifyPhone(
        fullPhoneNumber,
        (newVerificationId) {
          if (mounted) {
            setState(() {
              _currentVerificationId = newVerificationId;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.otpResentSuccessfully),
                backgroundColor: Colors.green,
              ),
            );
            _startTimer();
          }
        },
        (error) {
          if (mounted) {
            _clearFields(error: error);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        },
        (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.phoneNumberVerifiedSuccessfully),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/home');
          }
        },
      );
    } catch (e) {
      if (mounted) {
        _clearFields(error: e.toString());
      }
    }
  }

  // ✅ FIX: Safe phone number display
  String _getDisplayPhoneNumber() {
    final phone = widget.phoneNumber;
    if (phone.startsWith('+91')) {
      return phone.substring(3);
    } else if (phone.length == 10) {
      return phone;
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final displayError = authState.error ?? _localError;

    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.deepNavy),
          onPressed: _isSubmitting ? null : () => context.pop(),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          l10n.verifyYourNumber,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.deepNavy,
                          ),
                        ),
                      ),
                      OtpPasteButton(
                        onPaste: _pasteFromClipboard,
                        enabled: !isLoading && !_isSubmitting,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.otpSentTo(_getDisplayPhoneNumber()),
                    style: const TextStyle(
                      color: AppColors.slateBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // OTP Input Fields with design system styling
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final fields = <Widget>[];
                      for (var index = 0; index < 6; index++) {
                        fields.add(
                          Expanded(
                            child: SizedBox(
                              height: 60,
                              child: Semantics(
                                label: 'OTP input field ${index + 1} of 6',
                                textField: true,
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  enabled: !isLoading && !_isSubmitting,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(1),
                                  ],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.deepNavy,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: "",
                                    contentPadding: EdgeInsets.zero,
                                    filled: true,
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: _controllers[index].text.isNotEmpty 
                                            ? AppColors.mustardGold 
                                            : AppColors.outline,
                                        width: _controllers[index].text.isNotEmpty ? 1.5 : 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.deepNavy,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.error, 
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    // Handle backspace properly
                                    if (value.isEmpty && index > 0) {
                                      _focusNodes[index - 1].requestFocus();
                                    } else if (value.isNotEmpty) {
                                      if (index < 5) {
                                        _focusNodes[index + 1].requestFocus();
                                      }
                                      if (index == 5) {
                                        FocusScope.of(context).unfocus();
                                      }
                                    }
                                    // Clear error on typing
                                    if (_localError != null) {
                                      setState(() {
                                        _localError = null;
                                      });
                                    }
                                    _checkAndSubmit();
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                        if (index < 5) {
                          fields.add(const SizedBox(width: 8));
                        }
                      }
                      return FocusScope(
                        child: FocusTraversalGroup(
                          child: Row(children: fields),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // Verify OTP button
                  ElevatedButton(
                    onPressed: (isLoading || _isSubmitting) ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: AppColors.mustardGold,
                      foregroundColor: AppColors.deepNavy,
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.deepNavy,
                            ),
                          )
                        : Text(
                            l10n.verifyOtp,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.deepNavy,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Resend countdown or button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.didntReceiveOtp,
                        style: const TextStyle(
                          color: AppColors.slateBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      _secondsRemaining > 0
                          ? Text(
                              l10n.resendIn(
                                '0:${_secondsRemaining.toString().padLeft(2, '0')}',
                              ),
                              style: const TextStyle(
                                color: AppColors.deepNavy,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : TextButton(
                              onPressed: (isLoading || _isSubmitting) 
                                  ? null 
                                  : _resendOtp,
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.deepNavy,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 8,
                                ),
                              ),
                              child: Text(
                                l10n.resend,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
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

class OtpPasteButton extends StatelessWidget {
  final VoidCallback onPaste;
  final bool enabled;

  const OtpPasteButton({
    super.key,
    required this.onPaste,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: enabled ? onPaste : null,
      icon: const Icon(Icons.content_paste_rounded, size: 18),
      label: const Text('Paste'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.legalGold,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
