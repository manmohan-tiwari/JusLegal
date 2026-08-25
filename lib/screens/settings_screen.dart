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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: Text(l10n.deleteAccountTitle),
          content: Text(l10n.deleteAccountMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryNavy,
              ),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.unableToDeleteAccount)),
      );
      return;
    }

    Future<void> cleanupAndNavigateToLogin() async {
      await SharedPreferences.getInstance().then((p) => p.clear());
      await Hive.deleteFromDisk();
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      context.go('/login');
    }

    Future<void> attemptDelete() async {
      await user.delete();
    }

    try {
      await attemptDelete();
      await cleanupAndNavigateToLogin();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        try {
          final googleUser = await GoogleSignIn().signIn();
          final googleAuth = await googleUser?.authentication;
          final accessToken = googleAuth?.accessToken;
          final idToken = googleAuth?.idToken;

          if (accessToken == null || idToken == null) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.reauthenticationFailed)),
            );
            return;
          }

          final credential = GoogleAuthProvider.credential(
            accessToken: accessToken,
            idToken: idToken,
          );

          await user.reauthenticateWithCredential(credential);
          await attemptDelete();
          await cleanupAndNavigateToLogin();
        } on FirebaseAuthException catch (e2) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e2.message ?? l10n.unableToDeleteAccount)),
          );
        } catch (_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.unableToDeleteAccount)),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? l10n.unableToDeleteAccount)),
        );
      }
    } catch (_) {
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
                onTap: () => context.go('/privacy-policy'),
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
