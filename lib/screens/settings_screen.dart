import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juslegal/l10n/gen/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/config/theme_config.dart';
import '../core/constants/app_config.dart';
import '../core/services/analytics_service.dart';
import '../providers/locale_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = AppConfig.appVersion;
  String _buildNumber = AppConfig.appBuildNumber;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _showAccountDeletionDialog(AppLocalizations l10n) async {
    final deleteTextController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final typedValue = deleteTextController.text.trim();
            final canDelete = typedValue == 'DELETE';
            return AlertDialog(
              backgroundColor: AppColors.background,
              scrollable: true,
              title: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.red, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.deleteAccountTitle,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      l10n.deleteAccountMessage,
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.deleteAccountConfirmMessage,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.typeDeleteToConfirm,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: deleteTextController,
                    onChanged: (_) => setDialogState(() {}),
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.typeDeleteHint,
                      hintStyle: TextStyle(
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade400,
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: canDelete
                                ? Colors.red
                                : AppColors.primaryNavy),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.deleteButtonDisabledHint,
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          canDelete ? Colors.green.shade700 : Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryNavy,
                  ),
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: canDelete
                      ? () => Navigator.of(dialogContext).pop(true)
                      : null,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: canDelete ? Colors.red : Colors.grey.shade300,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(l10n.delete),
                ),
              ],
            );
          },
        );
      },
    );
    deleteTextController.dispose();

    if (confirmed != true) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.unableToDeleteAccount)),
      );
      return;
    }

    Future<void> cleanupAndNavigateToLogin({String? successMessage}) async {
      try {
        await SafeAnalytics.setUserId(id: null);
      } catch (_) {}
      try {
        SafeAnalytics.reset();
      } catch (_) {}
      try {
        await SharedPreferences.getInstance().then((p) => p.clear());
      } catch (_) {}
      try {
        if (Hive.isBoxOpen('cases')) {
          final casesBox = Hive.box('cases');
          await casesBox.clear();
        }
        if (Hive.isBoxOpen('settings')) {
          final settingsBox = Hive.box('settings');
          await settingsBox.clear();
        }
      } catch (_) {}
      try {
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
      } catch (_) {}
      if (!mounted) return;
      if (successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      context.go('/login');
    }

    Future<void> attemptDelete() async {
      await user.delete();
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: AppColors.background,
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    l10n.deletingAccount,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Future<bool> handleReauthRequired() async {
      Navigator.of(context).pop();

      final providerData = user.providerData;
      String? method;
      for (final p in providerData) {
        if (p.providerId == GoogleAuthProvider.GOOGLE_SIGN_IN_METHOD ||
            p.providerId == 'google.com') {
          method = 'google';
          break;
        }
        if (p.providerId == EmailAuthProvider.EMAIL_PASSWORD_SIGN_IN_METHOD ||
            p.providerId == 'password') {
          method = 'password';
          break;
        }
        if (p.providerId == PhoneAuthProvider.PHONE_SIGN_IN_METHOD ||
            p.providerId == 'phone') {
          method = 'phone';
          break;
        }
      }

      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.requiresRecentLogin),
          duration: const Duration(seconds: 3),
        ),
      );

      if (method == 'google') {
        try {
          final googleUser = await GoogleSignIn().signIn();
          final googleAuth = await googleUser?.authentication;
          final accessToken = googleAuth?.accessToken;
          final idToken = googleAuth?.idToken;

          if (accessToken == null || idToken == null) {
            if (!mounted) return false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.reauthenticationFailed)),
            );
            return false;
          }

          final credential = GoogleAuthProvider.credential(
            accessToken: accessToken,
            idToken: idToken,
          );

          await user.reauthenticateWithCredential(credential);
          return true;
        } on FirebaseAuthException catch (e) {
          if (!mounted) return false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? l10n.reauthenticationFailed)),
          );
          return false;
        } catch (_) {
          if (!mounted) return false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.reauthenticationFailed)),
          );
          return false;
        }
      }

      if (method == 'password') {
        if (!mounted) return false;
        final email = user.email ?? '';
        final password = await showDialog<String?>(
          context: context,
          builder: (pwdCtx) {
            final pwdController = TextEditingController();
            return StatefulBuilder(
              builder: (ctx, setPwdState) {
                return AlertDialog(
                  backgroundColor: AppColors.background,
                  title: Text(l10n.reauthenticationRequired),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        email.isNotEmpty ? email : l10n.email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: pwdController,
                        obscureText: true,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: l10n.password,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        onSubmitted: (_) =>
                            Navigator.of(pwdCtx).pop(pwdController.text),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(pwdCtx).pop(null),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: pwdController.text.isNotEmpty
                          ? () =>
                              Navigator.of(pwdCtx).pop(pwdController.text)
                          : null,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryNavy,
                      ),
                      child: Text(l10n.ok),
                    ),
                  ],
                );
              },
            );
          },
        );

        if (password == null || password.isEmpty) {
          if (!mounted) return false;
          return false;
        }

        try {
          final credential = EmailAuthProvider.credential(
            email: email,
            password: password,
          );
          await user.reauthenticateWithCredential(credential);
          return true;
        } on FirebaseAuthException catch (e) {
          if (!mounted) return false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message ?? l10n.reauthenticationFailed),
            ),
          );
          return false;
        } catch (_) {
          if (!mounted) return false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.reauthenticationFailed)),
          );
          return false;
        }
      }

      if (method == 'phone' || method == null) {
        try {
          await FirebaseAuth.instance.signOut();
          await GoogleSignIn().signOut();
        } catch (_) {}
        if (!mounted) return false;
        context.go('/login');
        return false;
      }

      return false;
    }

    try {
      await attemptDelete();
      Navigator.of(context).pop();
      await cleanupAndNavigateToLogin(
          successMessage: l10n.accountDeletedSuccess);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        final reauthOk = await handleReauthRequired();
        if (!reauthOk) {
          try {
            Navigator.of(context).pop();
          } catch (_) {}
          return;
        }
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            return PopScope(
              canPop: false,
              child: AlertDialog(
                backgroundColor: AppColors.background,
                content: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        l10n.deletingAccount,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        try {
          await attemptDelete();
          Navigator.of(context).pop();
          await cleanupAndNavigateToLogin(
              successMessage: l10n.accountDeletedSuccess);
        } on FirebaseAuthException catch (e2) {
          Navigator.of(context).pop();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e2.message ?? l10n.unableToDeleteAccount),
            ),
          );
        } catch (_) {
          Navigator.of(context).pop();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.unableToDeleteAccount)),
          );
        }
      } else {
        Navigator.of(context).pop();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? l10n.unableToDeleteAccount)),
        );
      }
    } catch (_) {
      Navigator.of(context).pop();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.unableToDeleteAccount)),
      );
    }
  }

  void _showDisclaimerDialog(AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: Text(
            l10n.legalDisclaimer,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            AppConfig.onboardingDisclaimer,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryNavy,
              ),
              child: Text(l10n.ok),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final isHindi = locale.languageCode == 'hi';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.primaryNavy,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: Text(
                  l10n.preferences.toUpperCase(),
                  style: const TextStyle(
                    letterSpacing: 1.0,
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const Divider(indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                subtitle: Text(
                  isHindi ? l10n.languageSubtitleHindi : l10n.languageSubtitleEnglish,
                ),
                trailing: Switch(
                  value: isHindi,
                  onChanged: (_) => ref.read(localeProvider.notifier).toggle(),
                ),
              ),
              const Divider(indent: 16, endIndent: 16),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: Text(
                  l10n.appInfo.toUpperCase(),
                  style: const TextStyle(
                    letterSpacing: 1.0,
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              ListTile(
                title: Text(l10n.appNameLabel),
                subtitle: Text(AppConfig.appName),
              ),
              const Divider(indent: 16, endIndent: 16),
              ListTile(
                title: Text(l10n.appVersion),
                trailing: Text(
                  'v$_appVersion+$_buildNumber',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const Divider(indent: 16, endIndent: 16),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: Text(
                  l10n.legal.toUpperCase(),
                  style: const TextStyle(
                    letterSpacing: 1.0,
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              ListTile(
                title: Text(l10n.privacyPolicy),
                onTap: () => _launchURL(AppConfig.privacyPolicyUrl),
                trailing: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
              ),
              const Divider(indent: 16, endIndent: 16),
              ListTile(
                title: Text(l10n.terms),
                onTap: () => _launchURL(AppConfig.termsOfServiceUrl),
                trailing: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
              ),
              const Divider(indent: 16, endIndent: 16),
              ListTile(
                title: Text(l10n.website),
                onTap: () => _launchURL(AppConfig.websiteUrl),
                trailing: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
              ),
              const Divider(indent: 16, endIndent: 16),
              ListTile(
                title: Text(l10n.disclaimer),
                onTap: () => _showDisclaimerDialog(l10n),
                trailing: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
              ),
              const Divider(indent: 16, endIndent: 16),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: Text(
                  l10n.account.toUpperCase(),
                  style: const TextStyle(
                    letterSpacing: 1.0,
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              ListTile(
                title: Text(l10n.deleteAccount),
                onTap: () => _showAccountDeletionDialog(l10n),
                trailing: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
