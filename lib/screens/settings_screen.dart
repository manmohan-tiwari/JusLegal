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

import 'package:juslegal/core/core.dart';

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
                backgroundColor: AppColors.warmOffWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                scrollable: true,
                title: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFC62828), size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.deleteAccountTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.deepNavy,
                        ),
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
                        color: AppColors.palePeach,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE8C8B5)),
                      ),
                      child: Text(
                        l10n.deleteAccountMessage,
                        style: const TextStyle(
                          color: Color(0xFF5A1A1A),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.deleteAccountConfirmMessage,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.slateBlue,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.typeDeleteToConfirm,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepNavy,
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
                        color: AppColors.deepNavy,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.typeDeleteHint,
                        hintStyle: const TextStyle(
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slateBlue,
                        ),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: canDelete
                                  ? const Color(0xFFC62828)
                                  : AppColors.deepNavy,
                              width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.deleteButtonDisabledHint,
                      style: TextStyle(
                        fontSize: 11,
                        color: canDelete
                            ? const Color(0xFF2E7D32)
                            : AppColors.slateBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.slateBlue,
                    ),
                    child: Text(l10n.cancel),
                  ),
                  TextButton(
                    onPressed: canDelete
                        ? () => Navigator.of(dialogContext).pop(true)
                        : null,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: canDelete
                          ? const Color(0xFFC62828)
                          : const Color(0xFFD4E2EC),
                      disabledBackgroundColor: const Color(0xFFD4E2EC),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
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

    if (!mounted) return;
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
        final pwdController = TextEditingController();
        final String? password;
        try {
          password = await showDialog<String?>(
            context: context,
            builder: (pwdCtx) {
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
        } finally {
          pwdController.dispose();
        }

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
      if (!mounted) return;
      Navigator.of(context).pop();
      await cleanupAndNavigateToLogin(
          successMessage: l10n.accountDeletedSuccess);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        final reauthOk = await handleReauthRequired();
        if (!reauthOk) {
          if (!mounted) return;
          try {
            Navigator.of(context).pop();
          } catch (_) {}
          return;
        }
        if (!mounted) return;
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
          if (!mounted) return;
          Navigator.of(context).pop();
          await cleanupAndNavigateToLogin(
              successMessage: l10n.accountDeletedSuccess);
        } on FirebaseAuthException catch (e2) {
          if (!mounted) return;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e2.message ?? l10n.unableToDeleteAccount),
            ),
          );
        } catch (_) {
          if (!mounted) return;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.unableToDeleteAccount)),
          );
        }
      } else {
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? l10n.unableToDeleteAccount)),
        );
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pop();
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
          backgroundColor: AppColors.warmOffWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.legalDisclaimer,
            style: const TextStyle(
              color: AppColors.deepNavy,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.paleBlue,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD4E2EC)),
            ),
            child: Text(
              AppConfig.onboardingDisclaimer,
              style: const TextStyle(
                color: AppColors.deepNavy,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mustardGold,
                foregroundColor: AppColors.deepNavy,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                l10n.ok,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(
            color: AppColors.deepNavy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: AppColors.warmOffWhite,
        elevation: 0,
        foregroundColor: AppColors.deepNavy,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.divider, height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Card
              if (user != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outline),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.paleBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD4E2EC)),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person_rounded,
                            color: AppColors.deepNavy,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayName ??
                                  user.email ??
                                  user.phoneNumber ??
                                  'JusLegal User',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.deepNavy,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.email ?? user.phoneNumber ?? 'Verified Account',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.slateBlue,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],



              // App Info Section
              _SettingsSection(
                title: l10n.appInfo,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 2),
                    title: Text(
                      l10n.appNameLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    trailing: Text(
                      AppConfig.appName,
                      style: const TextStyle(
                        color: AppColors.slateBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Divider(
                      indent: 16, endIndent: 16, height: 1, color: AppColors.outline),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 2),
                    title: Text(
                      l10n.appVersion,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    trailing: Text(
                      'v$_appVersion+$_buildNumber',
                      style: const TextStyle(
                        color: AppColors.slateBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Legal Section
              _SettingsSection(
                title: l10n.legal,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 2),
                    leading: const Icon(Icons.shield_outlined,
                        color: AppColors.deepNavy, size: 20),
                    title: const Text(
                      'Privacy Preferences',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    subtitle: const Text(
                      'Manage analytics and data collection',
                      style: TextStyle(fontSize: 11, color: AppColors.slateBlue),
                    ),
                    onTap: () => context.push('/home/privacy-consent'),
                    trailing: const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.slateBlue,
                    ),
                  ),
                  const Divider(
                      indent: 16, endIndent: 16, height: 1, color: AppColors.outline),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 2),
                    title: Text(
                      l10n.privacyPolicy,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    onTap: () => _launchURL(AppConfig.privacyPolicyUrl),
                    trailing: const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.slateBlue,
                    ),
                  ),
                  const Divider(
                      indent: 16, endIndent: 16, height: 1, color: AppColors.outline),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 2),
                    title: Text(
                      l10n.terms,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    onTap: () => _launchURL(AppConfig.termsOfServiceUrl),
                    trailing: const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.slateBlue,
                    ),
                  ),
                  const Divider(
                      indent: 16, endIndent: 16, height: 1, color: AppColors.outline),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 2),
                    title: Text(
                      l10n.website,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    onTap: () => _launchURL(AppConfig.websiteUrl),
                    trailing: const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.slateBlue,
                    ),
                  ),
                  const Divider(
                      indent: 16, endIndent: 16, height: 1, color: AppColors.outline),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 2),
                    title: Text(
                      l10n.disclaimer,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    onTap: () => _showDisclaimerDialog(l10n),
                    trailing: const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.slateBlue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Account Section
              _SettingsSection(
                title: l10n.account,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 2),
                    leading: const Icon(Icons.delete_outline_rounded,
                        color: Color(0xFFC62828), size: 22),
                    title: Text(
                      l10n.deleteAccount,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFC62828),
                      ),
                    ),
                    onTap: () => _showAccountDeletionDialog(l10n),
                    trailing: const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Color(0xFFC62828),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.slateBlue,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}
