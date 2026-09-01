import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:juslegal/core/core.dart';
import '../providers/ai_provider.dart';
import '../providers/complaint_provider.dart';
import '../providers/problem_provider.dart';
import '../widgets/pro_upgrade_sheet.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/legal_disclaimer_banner.dart';
import '../services/storage_service.dart';
import '../services/pdf/legal_pdf_models.dart';
import '../services/pdf/legal_pdf_service.dart';

class ComplaintGeneratorScreen extends ConsumerStatefulWidget {
  const ComplaintGeneratorScreen({super.key});

  @override
  ConsumerState<ComplaintGeneratorScreen> createState() =>
      _ComplaintGeneratorScreenState();
}

class _ComplaintGeneratorScreenState
    extends ConsumerState<ComplaintGeneratorScreen> {
  final TextEditingController _letterController = TextEditingController();
  bool _isGenerating = false;
  bool _isDownloading = false;
  bool _isEditing = false;
  String _tone = 'Formal';

  String? _lastErrorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generate();
    });
  }

  @override
  void dispose() {
    _letterController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final state = ref.read(complaintProvider);
    if (!state.isPro && state.generatedCount >= state.freeLimit) {
      showModalBottomSheet(
          context: context,
          showDragHandle: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          builder: (_) => const ProUpgradeSheet());
      return;
    }

    final result = ref.read(lastResultProvider);
    if (result == null) {
      if (mounted) {
        setState(() {
          _lastErrorMessage = 'Please analyze your problem first.';
        });
      }
      return;
    }

    setState(() {
      _isGenerating = true;
      _isEditing = false;
    });

    try {
      final aiService = ref.read(aiServiceProvider);
      final problem = ref.read(problemProvider);
      final applicant = await _applicantInfo();

      final authorityName = result.authorities.isNotEmpty
          ? result.authorities.first
          : 'Concerned Authority';
      final parsedAuthority = authorityName is Map
          ? (authorityName['name'] ?? 'Concerned Authority')
          : authorityName.toString();

      final generatedText = await aiService.generateLetter(
        letterType: _tone.toLowerCase(),
        category: problem.category,
        problemDescription: problem.description,
        userRights: result.userRights,
        applicableLaw: result.applicableLaw,
        steps: result.steps,
        senderName: applicant.fullName,
        senderAddress: applicant.address,
        opponentName: parsedAuthority,
        incidentDate: DateFormat('dd MMM yyyy').format(DateTime.now()),
      );

      String cleanText = generatedText.trim();
      if (cleanText.startsWith('```')) {
        final lines = cleanText.split('\n');
        if (lines.length > 2) {
          cleanText = lines.sublist(1, lines.length - 1).join('\n');
        }
      }

      _letterController.text = cleanText;

      await ref.read(complaintProvider.notifier).increment();
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastErrorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: _letterController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color(0xFF10B981),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Copied to clipboard',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }

  void _download() async {
    setState(() => _isDownloading = true);
    try {
      final locale = Localizations.localeOf(context).languageCode;
      final result = ref.read(lastResultProvider);
      final authority = result?.authorities.isNotEmpty == true
          ? result!.authorities.first.toString()
          : 'Concerned Authority';
      final applicant = await _applicantInfo();
      final doc = CourtComplaintDocument(
        title: 'Consumer Complaint',
        district: '[District]',
        state: '[State]',
        complainant: applicant,
        oppositeParty:
            OppositePartyInfo(name: authority, address: 'Address not provided'),
        factsOfCase: const [],
        reliefSought: result?.steps.map((step) => step.toString()).toList() ??
            const ['Appropriate relief as per law'],
      );
      await LegalPdfService.showPrintPreview(
        doc,
        locale,
      );
      final storage = StorageService();
      final prefs = await storage.prefs();
      await prefs.setString(
          'last_downloaded_letter', _letterController.text.length.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color(0xFF10B981),
            duration: const Duration(seconds: 2),
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'PDF Downloaded successfully',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 3),
            content: Text('Failed to download PDF: ${e.toString()}',
                style: const TextStyle(color: Colors.white)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  /// Uses any saved profile fields first, then Firebase Auth for identity
  /// values. Auth does not expose a postal address, so the explicit fallback
  /// remains visible only when the user has not supplied one anywhere.
  Future<PersonInfo> _applicantInfo() async {
    final prefs = await StorageService().prefs();
    String value(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        final candidate = prefs.getString(key)?.trim();
        if (candidate != null && candidate.isNotEmpty) return candidate;
      }
      return fallback;
    }

    final user = FirebaseAuth.instance.currentUser;
    return PersonInfo(
      fullName: value(const ['user_name', 'full_name', 'name'],
          fallback: user?.displayName?.trim().isNotEmpty == true
              ? user!.displayName!.trim()
              : 'Applicant'),
      address: value(const ['user_address', 'address', 'profile_address'],
          fallback: 'Address not provided'),
      mobile: value(const ['user_mobile', 'mobile', 'phone'],
          fallback: user?.phoneNumber ?? ''),
      email: value(const ['user_email', 'email'], fallback: user?.email ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(lastResultProvider);

    final authorityName = result?.authorities.isNotEmpty == true
        ? result!.authorities.first
        : 'Concerned Authority';
    final parsedAuthority = authorityName is Map
        ? (authorityName['name'] ?? 'Concerned Authority')
        : authorityName.toString();

    final category = result?.category ?? 'General Complaint';
    final date = DateFormat('dd MMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Letter'),
        leading: const BackButton(),
      ),
      body: _lastErrorMessage != null
          ? Center(
              child: Card(
                color: Color(0xFFF5F7FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFDC2626),
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Something went wrong',
                        style: const TextStyle(
                            color: Color(0xFF1F2937),
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _lastErrorMessage ?? '',
                        style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                            fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isGenerating
                            ? null
                            : () {
                                HapticFeedback.lightImpact();
                                setState(() => _lastErrorMessage = null);
                                _generate();
                              },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Card
                        Card(
                          color: AppColors.surface,
                          elevation: 0,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Recipient',
                                  style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  parsedAuthority,
                                  style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Chip(label: Text(category)),
                                    Text(
                                      date,
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tone Selector
                        const Text(
                          'Select Tone',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children:
                              ['Formal', 'Assertive', 'Concise'].map((tone) {
                            final isSelected = _tone == tone;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: OutlinedButton(
                                  onPressed: _isGenerating
                                      ? null
                                      : () {
                                          HapticFeedback.lightImpact();
                                          setState(() => _tone = tone);
                                          _generate();
                                        },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: isSelected
                                        ? AppColors.legalGold
                                        : AppColors.surfaceBright,
                                    foregroundColor: isSelected
                                        ? const Color(0xFF0B0F19)
                                        : AppColors.textPrimary,
                                    side: BorderSide(
                                        color: isSelected
                                            ? AppColors.legalGold
                                            : AppColors.border),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  child: Text(
                                    tone,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // Letter Preview Card
                        const Text(
                          'Letter Preview',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          color: AppColors.surface,
                          elevation: 0,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: TextButton.icon(
                                  onPressed: () =>
                                      setState(() => _isEditing = !_isEditing),
                                  icon: Icon(
                                    _isEditing
                                        ? Icons.lock_outline
                                        : Icons.edit_outlined,
                                    size: 18,
                                  ),
                                  label: Text(_isEditing
                                      ? 'Lock Letter'
                                      : 'Edit Letter'),
                                ),
                              ),
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: _isGenerating
                                    ? const ShimmerLoader()
                                    : TextField(
                                        controller: _letterController,
                                        readOnly: !_isEditing,
                                        maxLines: null,
                                        style: const TextStyle(
                                          color: Color(0xFF1F2937),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          height: 1.6,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          fillColor: Colors.transparent,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Regenerate Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Not satisfied?',
                              style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: _isGenerating ? null : _generate,
                              style: TextButton.styleFrom(
                                foregroundColor: Color(0xFF0052CC),
                              ),
                              child: const Text('Regenerate'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const LegalDisclaimerBanner(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Bottom Sticky Area
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F7FF),
                    border: Border(
                      top: BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isGenerating
                              ? null
                              : () {
                                  HapticFeedback.lightImpact();
                                  _copy();
                                },
                          child: const Text('Copy Text'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (_isGenerating || _isDownloading)
                              ? null
                              : () {
                                  HapticFeedback.lightImpact();
                                  _download();
                                },
                          child: _isDownloading
                              ? SizedBox(
                                  height: 20,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(
                                          Color(0xFF0052CC)),
                                      backgroundColor: Color(0xFF0052CC)
                                          .withValues(alpha: 0.15),
                                    ),
                                  ),
                                )
                              : const Text('Download / Print PDF'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: _isGenerating ||
                                _letterController.text.isEmpty
                            ? null
                            : () {
                                HapticFeedback.lightImpact();
                                final letterContent = _letterController.text;
                                final caseType = category;
                                Share.share(
                                  letterContent,
                                  subject: 'Complaint Letter - $caseType',
                                );
                              },
                        icon: const Icon(Icons.share_outlined),
                        color: Color(0xFF0052CC),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
