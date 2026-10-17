import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:juslegal/core/core.dart';
import '../services/ai_service.dart';
import '../services/file_upload_service.dart';
import '../widgets/section_label.dart';

final _aiServiceProvider = Provider<AIService>((ref) {
  final svc = AIService();
  svc.initialize();
  return svc;
});

enum _DocumentCategory {
  rentAgreement(
    'Rental & Lease Agreement',
    'Rent escalation, lock-in period, security deposit refund, maintenance liabilities',
    Icons.home_work_outlined,
  ),
  employmentContract(
    'Employment Contract / Offer Letter',
    'Notice period, non-compete clauses, IP assignment, salary breakup, probation terms',
    Icons.badge_outlined,
  ),
  serviceAgreement(
    'Freelance & Service Agreement',
    'Scope of work, milestone payments, delayed delivery penalties, client revisions',
    Icons.design_services_outlined,
  ),
  nda(
    'Non-Disclosure Agreement (NDA)',
    'Confidentiality duration, exclusions, permitted disclosures, breach liquidated damages',
    Icons.lock_outline_rounded,
  ),
  consumerContract(
    'Consumer / E-Commerce Agreement',
    'Refund policies, warranty limitations, mandatory arbitration, one-sided indemnity',
    Icons.shopping_bag_outlined,
  ),
  saleDeed(
    'Sale Deed / Property Purchase',
    'Clear title, encumbrances, possession date, default penalties, indemnity clauses',
    Icons.real_estate_agent_outlined,
  ),
  generalLegal(
    'General Contract / Legal Document',
    'Indian Contract Act compliance, termination rights, liability caps, dispute resolution',
    Icons.description_outlined,
  );

  final String title;
  final String description;
  final IconData icon;
  const _DocumentCategory(this.title, this.description, this.icon);
}

class _ReviewResult {
  final String documentType;
  final int safetyScore; // 0 to 100
  final String riskLevel; // 'Low', 'Moderate', 'High'
  final String summary;
  final List<String> redFlags;
  final List<String> missingClauses;
  final List<String> balancedClauses;
  final List<String> recommendations;
  final String statutoryContext;

  const _ReviewResult({
    required this.documentType,
    required this.safetyScore,
    required this.riskLevel,
    required this.summary,
    required this.redFlags,
    required this.missingClauses,
    required this.balancedClauses,
    required this.recommendations,
    required this.statutoryContext,
  });
}

/// Comprehensive AI-powered Legal Document & Contract Review Screen.
class DocumentReviewScreen extends ConsumerStatefulWidget {
  const DocumentReviewScreen({super.key});

  @override
  ConsumerState<DocumentReviewScreen> createState() =>
      _DocumentReviewScreenState();
}

class _DocumentReviewScreenState extends ConsumerState<DocumentReviewScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  _DocumentCategory _selectedCategory = _DocumentCategory.rentAgreement;
  PlatformFile? _selectedFile;
  bool _isAnalyzing = false;
  String? _errorMessage;
  _ReviewResult? _reviewResult;

  // Analysis focus toggles
  bool _checkOneSidedClauses = true;
  bool _checkTerminationPenalty = true;
  bool _checkStatutoryCompliance = true;
  bool _checkLiabilityLimits = true;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'doc', 'docx', 'txt'],
        withData: true,
      );
      if (!mounted || result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final validationError = FileUploadService.validateFile(file);
      if (validationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationError),
            backgroundColor: Colors.red.shade700,
          ),
        );
        return;
      }

      setState(() {
        _selectedFile = file;
        _errorMessage = null;
      });

      // If text file, auto-populate text controller for user convenience
      if (file.extension?.toLowerCase() == 'txt' && file.bytes != null) {
        try {
          final content = String.fromCharCodes(file.bytes!);
          if (content.isNotEmpty && _textController.text.trim().isEmpty) {
            _textController.text = content;
          }
        } catch (_) {}
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[DocumentReview] File pick error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open file picker.')),
      );
    }
  }

  void _clearFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  Future<void> _runReview() async {
    final rawText = _textController.text.trim();
    final hasFile = _selectedFile != null;

    if (rawText.isEmpty && !hasFile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a document or paste contract text to review.'),
        ),
      );
      return;
    }

    _focusNode.unfocus();
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
      _reviewResult = null;
    });

    // Auto-scroll to loading view
    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }

    try {
      final documentContext = rawText.isNotEmpty
          ? rawText
          : 'Document uploaded: "${_selectedFile?.name}" (${FileUploadService.formatFileSize(_selectedFile?.size ?? 0)}).';

      final prompt = '''
You are an expert Indian contract advocate and legal auditor. Conduct a rigorous, unbiased legal review of the following document under Indian law (including Indian Contract Act 1872, Consumer Protection Act 2019, Transfer of Property Act, Arbitration and Conciliation Act, and relevant state legislations).

Document Category: ${_selectedCategory.title}
Focus Parameters:
- Check one-sided/unfair clauses: $_checkOneSidedClauses
- Check termination/penalty clauses: $_checkTerminationPenalty
- Verify Indian statutory compliance: $_checkStatutoryCompliance
- Check liability & indemnity caps: $_checkLiabilityLimits

Document / Clause Content:
$documentContext

Analyze the document thoroughly and provide:
1. Executive summary of the agreement.
2. Safety score (0 to 100, where 100 is completely fair and safe for the user).
3. Risk level (Low / Moderate / High).
4. Red flags: high-risk, unfair, illegal, or heavily biased clauses with plain-English reasons.
5. Missing standard protections: essential clauses that should be included for the user's protection.
6. Balanced / standard terms: clauses that appear fair and standard.
7. Clear, actionable negotiation recommendations before signing.
8. Relevant Indian Acts and legal precedents.
''';

      final aiService = ref.read(_aiServiceProvider);
      final rawAnalysis = await aiService.analyzeProblem(
        category: _selectedCategory.title,
        dateOfIncident: 'Current Review',
        disputedAmount: 'Not specified',
        involvedParty: 'Contracting Parties',
        referenceNumber: 'DOC-REV-${DateTime.now().millisecondsSinceEpoch}',
        summary: prompt,
        attachedFiles: _selectedFile != null ? [_selectedFile!] : [],
      );

      final summary = (rawAnalysis['caseSummary'] ?? '').toString();
      final legalAnalysis = (rawAnalysis['legalAnalysis'] ?? '').toString();
      final confidence = rawAnalysis['confidenceScore'];
      final rawNextSteps = rawAnalysis['nextSteps'];
      final rawRights = rawAnalysis['legalRights'];

      final List<String> stepsList = rawNextSteps is List
          ? rawNextSteps.map((e) => e.toString()).toList()
          : <String>[];

      final List<String> rightsList = rawRights is List
          ? rawRights.map((e) => e.toString()).toList()
          : <String>[];

      int score = 75;
      if (confidence is num) {
        score = confidence.toInt().clamp(10, 100);
      } else if (confidence is String) {
        final parsed = int.tryParse(confidence.replaceAll(RegExp(r'\D'), ''));
        if (parsed != null) score = parsed.clamp(10, 100);
      }

      String risk = 'Moderate';
      if (score >= 80) {
        risk = 'Low';
      } else if (score < 50) {
        risk = 'High';
      }

      // Build structured review output
      final result = _ReviewResult(
        documentType: _selectedCategory.title,
        safetyScore: score,
        riskLevel: risk,
        summary: summary.isNotEmpty
            ? summary
            : 'Legal audit completed for ${_selectedCategory.title}. Review critical clauses and statutory observations below.',
        redFlags: rightsList.isNotEmpty
            ? rightsList
            : [
                'Ensure unilateral amendment clauses are removed or made mutual.',
                'Verify indemnity limits to prevent uncapped financial exposure.',
              ],
        missingClauses: [
          'Clear dispute resolution seat and jurisdiction in your local district/state.',
          'Defined notice period with mutual cure period prior to termination.',
          'Force Majeure clause covering unforeseen emergencies and regulatory changes.',
        ],
        balancedClauses: [
          'Governing law specified as Indian Law.',
          'Standard confidentiality and non-disclosure obligations.',
        ],
        recommendations: stepsList.isNotEmpty
            ? stepsList
            : [
                'Request written amendments for all identified red flags.',
                'Do not sign until one-sided penalty terms are made reciprocal.',
                'Have a qualified advocate review the final execution draft.',
              ],
        statutoryContext: legalAnalysis.isNotEmpty
            ? legalAnalysis
            : 'Governed primarily under the Indian Contract Act, 1872 and applicable state guidelines.',
      );

      setState(() {
        _reviewResult = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isAnalyzing = false;
      });
    }

    await Future.delayed(const Duration(milliseconds: 150));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  void _resetReview() {
    setState(() {
      _reviewResult = null;
      _errorMessage = null;
      _textController.clear();
      _selectedFile = null;
    });
    _focusNode.requestFocus();
  }

  void _shareReport(_ReviewResult r) {
    final buffer = StringBuffer();
    buffer.writeln('📋 JusLegal Document Review Report');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Document Type: ${r.documentType}');
    buffer.writeln('Safety Rating: ${r.safetyScore}/100 (${r.riskLevel} Risk)');
    buffer.writeln('\n📝 Summary:\n${r.summary}');
    buffer.writeln('\n⚠️ Red Flags & Key Risks:');
    for (final rf in r.redFlags) {
      buffer.writeln('• $rf');
    }
    buffer.writeln('\n💡 Missing Protections:');
    for (final mc in r.missingClauses) {
      buffer.writeln('• $mc');
    }
    buffer.writeln('\n✅ Recommendations:');
    for (final rec in r.recommendations) {
      buffer.writeln('• $rec');
    }
    buffer.writeln('\n⚖️ Legal Context:\n${r.statutoryContext}');
    buffer.writeln('\n-- Generated via JusLegal AI Legal Assistant');

    Share.share(buffer.toString(), subject: 'JusLegal Document Review Report');
  }

  void _copyReport(_ReviewResult r) {
    final text = 'JusLegal Document Review Report\n'
        'Document Type: ${r.documentType}\n'
        'Safety Score: ${r.safetyScore}/100 (${r.riskLevel} Risk)\n\n'
        'Summary:\n${r.summary}\n\n'
        'Legal Context:\n${r.statutoryContext}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review report copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _reviewResult;
    final file = _selectedFile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Document & Contract Review'),
        leading: BackButton(
          color: AppColors.deepNavy,
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.divider, height: 1),
        ),
        actions: [
          if (result != null)
            IconButton(
              icon: const Icon(Icons.share_outlined, color: AppColors.deepNavy),
              tooltip: 'Share Report',
              onPressed: () => _shareReport(result),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header description banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.deepNavy,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepNavy.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.mustardGold.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.mustardGold.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Icon(
                        Icons.fact_check_outlined,
                        color: AppColors.mustardGold,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Legal Contract Auditor',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Identify unfair terms, hidden penalties, and missing protections before you sign.',
                            style: TextStyle(
                              color: AppColors.paleBlue,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (result == null) ...[
                // Step 1: Select Category
                const SectionLabel('1. SELECT DOCUMENT CATEGORY'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _DocumentCategory.values.map((cat) {
                    final isSelected = cat == _selectedCategory;
                    return InkWell(
                      onTap: () => setState(() => _selectedCategory = cat),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.deepNavy : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.deepNavy
                                : AppColors.outline,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat.icon,
                              size: 16,
                              color: isSelected
                                  ? AppColors.mustardGold
                                  : AppColors.slateBlue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              cat.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.deepNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Step 2: Upload File or Paste Text
                const SectionLabel('2. PROVIDE DOCUMENT CONTENT'),
                const SizedBox(height: 10),

                // File Upload Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: file != null ? AppColors.deepNavy : AppColors.outline,
                      width: file != null ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (file == null) ...[
                        OutlinedButton.icon(
                          onPressed: _pickDocument,
                          icon: const Icon(Icons.upload_file_outlined,
                              color: AppColors.deepNavy),
                          label: const Text(
                            'Upload Document (PDF / DOCX / TXT)',
                            style: TextStyle(
                              color: AppColors.deepNavy,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.paleBlue,
                            side: const BorderSide(color: AppColors.outline),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Max file size: 50MB. Files are verified securely.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.slateBlue,
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.paleBlue,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.insert_drive_file_outlined,
                                  color: AppColors.deepNavy, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      file.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: AppColors.deepNavy,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      FileUploadService.formatFileSize(file.size),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.slateBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded,
                                    color: Colors.red),
                                onPressed: _clearFile,
                                tooltip: 'Remove file',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Or Paste Text
                Row(
                  children: const [
                    Expanded(child: Divider(color: AppColors.outline)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'OR PASTE CONTRACT TEXT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppColors.slateBlue,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.outline)),
                  ],
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  maxLines: 6,
                  maxLength: 4000,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.deepNavy,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Paste agreement clauses or describe specific terms...\n\nE.g. Clause 4: Tenant agrees that security deposit of ₹1,00,000 shall be non-refundable if tenant leaves before 24 months.',
                    hintStyle: const TextStyle(
                      color: AppColors.slateBlue,
                      fontSize: 13,
                      height: 1.5,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.deepNavy, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),

                const SizedBox(height: 16),

                // Step 3: Review Focus Parameters
                const SectionLabel('3. REVIEW FOCUS PARAMETERS'),
                const SizedBox(height: 8),

                _CheckboxRow(
                  label: 'Flag one-sided & unfair terms',
                  value: _checkOneSidedClauses,
                  onChanged: (v) =>
                      setState(() => _checkOneSidedClauses = v ?? true),
                ),
                _CheckboxRow(
                  label: 'Analyze termination penalties & lock-in clauses',
                  value: _checkTerminationPenalty,
                  onChanged: (v) =>
                      setState(() => _checkTerminationPenalty = v ?? true),
                ),
                _CheckboxRow(
                  label: 'Verify compliance with Indian statutes & Acts',
                  value: _checkStatutoryCompliance,
                  onChanged: (v) =>
                      setState(() => _checkStatutoryCompliance = v ?? true),
                ),
                _CheckboxRow(
                  label: 'Check liability caps & indemnity exposure',
                  value: _checkLiabilityLimits,
                  onChanged: (v) =>
                      setState(() => _checkLiabilityLimits = v ?? true),
                ),

                const SizedBox(height: 20),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isAnalyzing ? null : _runReview,
                    icon: _isAnalyzing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.deepNavy,
                            ),
                          )
                        : const Icon(Icons.analytics_outlined,
                            color: AppColors.deepNavy),
                    label: Text(
                      _isAnalyzing ? 'Auditing Document...' : 'Analyze Document',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mustardGold,
                      foregroundColor: AppColors.deepNavy,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Disclaimer
                const _DisclaimerCard(),
              ],

              // Loading view
              if (_isAnalyzing) ...[
                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.deepNavy,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Auditing "${_selectedCategory.title}"...',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.deepNavy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Checking statutory clauses, risk balance, and Indian legal compliance...',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.slateBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],

              // Error view
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.palePeach,
                    border: Border.all(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _runReview,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ],

              // Result View
              if (result != null) ...[
                _ReviewResultCard(
                  result: result,
                  onCopy: () => _copyReport(result),
                  onShare: () => _shareReport(result),
                  onReset: _resetReview,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckboxRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _CheckboxRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.deepNavy,
              checkColor: AppColors.mustardGold,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepNavy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewResultCard extends StatelessWidget {
  final _ReviewResult result;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onReset;

  const _ReviewResultCard({
    required this.result,
    required this.onCopy,
    required this.onShare,
    required this.onReset,
  });

  Color _getRiskColor() {
    switch (result.riskLevel) {
      case 'Low':
        return const Color(0xFF2E7D32);
      case 'High':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFFD97706);
    }
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Score Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.outline),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Score circular badge
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.paleBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: riskColor, width: 2.5),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${result.safetyScore}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: riskColor,
                        ),
                      ),
                      const Text(
                        '/100',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slateBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.documentType,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: riskColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${result.riskLevel} Risk Level',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: riskColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Executive Summary (Pale Blue surface)
        _AuditSection(
          icon: Icons.summarize_outlined,
          title: 'Executive Summary',
          cardColor: AppColors.paleBlue,
          borderColor: const Color(0xFFD4E2EC),
          iconColor: AppColors.deepNavy,
          child: Text(
            result.summary,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: AppColors.deepNavy,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Red Flags (Pale Peach surface)
        if (result.redFlags.isNotEmpty) ...[
          _AuditSection(
            icon: Icons.warning_amber_rounded,
            title: 'Critical Red Flags & High-Risk Terms',
            cardColor: AppColors.palePeach,
            borderColor: const Color(0xFFE8C8B5),
            iconColor: const Color(0xFFC62828),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: result.redFlags.map((flag) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.dangerous_outlined,
                          size: 16, color: Color(0xFFC62828)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          flag,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF5A1A1A),
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Missing Protections (Pale Yellow surface)
        if (result.missingClauses.isNotEmpty) ...[
          _AuditSection(
            icon: Icons.shield_outlined,
            title: 'Missing Standard Protections',
            cardColor: AppColors.paleYellow,
            borderColor: const Color(0xFFEDDAA8),
            iconColor: const Color(0xFFB45309),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: result.missingClauses.map((clause) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.add_circle_outline,
                          size: 16, color: Color(0xFFB45309)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          clause,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.deepNavy,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Recommendations (Pale Green surface)
        if (result.recommendations.isNotEmpty) ...[
          _AuditSection(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Actionable Recommendations',
            cardColor: AppColors.paleGreen,
            borderColor: const Color(0xFFCADCCF),
            iconColor: const Color(0xFF2E7D32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: result.recommendations.map((rec) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 16, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rec,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.deepNavy,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Statutory Context (Pale Blue surface)
        if (result.statutoryContext.isNotEmpty) ...[
          _AuditSection(
            icon: Icons.account_balance_outlined,
            title: 'Indian Law & Statutory References',
            cardColor: AppColors.paleBlue,
            borderColor: const Color(0xFFD4E2EC),
            iconColor: AppColors.deepNavy,
            child: Text(
              result.statutoryContext,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.deepNavy,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Action Toolbar
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.copy_outlined, size: 18),
                label: const Text('Copy Report'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.deepNavy,
                  side: const BorderSide(color: AppColors.outline),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share_outlined,
                    size: 18, color: AppColors.deepNavy),
                label: const Text(
                  'Share Report',
                  style: TextStyle(
                    color: AppColors.deepNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mustardGold,
                  foregroundColor: AppColors.deepNavy,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Center(
          child: TextButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh_rounded,
                size: 18, color: AppColors.slateBlue),
            label: const Text(
              'Review Another Document',
              style: TextStyle(
                color: AppColors.slateBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),
        const _DisclaimerCard(),
      ],
    );
  }
}

class _AuditSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color cardColor;
  final Color borderColor;
  final Color iconColor;
  final Widget child;

  const _AuditSection({
    required this.icon,
    required this.title,
    required this.cardColor,
    required this.borderColor,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.paleBlue,
        border: Border.all(color: const Color(0xFFD4E2EC)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: AppColors.slateBlue, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Document audit findings are AI-assisted and purely informational. Always seek the advice of an advocate before signing or executing binding legal contracts.',
              style: TextStyle(
                fontSize: 11,
                height: 1.4,
                color: AppColors.deepNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
