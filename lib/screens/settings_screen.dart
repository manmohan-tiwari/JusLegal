import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_config.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_colors.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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

  Future<void> _showAccountDeletionDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text('Delete account?'),
          content: const Text(
            'This will permanently delete your Firebase account. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryNavy,
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
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
        const SnackBar(content: Text('Unable to delete account. Please log in again.')),
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
              const SnackBar(content: Text('Re-authentication failed. Please try again.')),
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
            SnackBar(content: Text(e2.message ?? 'Unable to delete account. Please try again.')),
          );
        } catch (_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to delete account. Please try again.')),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Unable to delete account.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to delete account. Please try again.')),
      );
    }
  }

  void _showDisclaimerDialog() {

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: Text(
            'Legal Disclaimer',
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            AppStrings.onboardingDisclaimer,
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
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
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
                  'PREFERENCES',
                  style: const TextStyle(
                    letterSpacing: 1.0,
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              const Divider(indent: 16, endIndent: 16),

              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: Text(
                  'APP INFO',
                  style: const TextStyle(
                    letterSpacing: 1.0,
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              ListTile(
                title: const Text('App Name'),
                subtitle: Text(AppConfig.appName),
              ),
              const Divider(indent: 16, endIndent: 16),
              ListTile(
                title: const Text('App Version'),
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
                  'LEGAL',
                  style: const TextStyle(
                    letterSpacing: 1.0,
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Privacy Policy'),
                onTap: () {
                  context.go('/privacy-policy');
                },
                trailing: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
              ),
              const Divider(indent: 16, endIndent: 16),

              ListTile(
                title: const Text('Terms'),
                onTap: () => _launchURL(AppConfig.termsOfServiceUrl),
                trailing: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
              ),
              const Divider(indent: 16, endIndent: 16),

              ListTile(
                title: const Text('Website'),
                onTap: () => _launchURL(AppConfig.websiteUrl),
                trailing: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
              ),
              const Divider(indent: 16, endIndent: 16),

              ListTile(
                title: const Text('Disclaimer'),
                onTap: _showDisclaimerDialog,
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
                  'ACCOUNT',
                  style: const TextStyle(
                    letterSpacing: 1.0,
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              ListTile(
                title: const Text('Delete account'),
                onTap: _showAccountDeletionDialog,
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
