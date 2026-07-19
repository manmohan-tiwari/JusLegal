import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../services/ai_service.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final _aiServiceProvider = Provider<AIService>((ref) {
  final svc = AIService();
  svc.initialize();
  return svc;
});

// ── Case type suggestions ─────────────────────────────────────────────────────

const List<String> _caseTypeSuggestions = [
  'Consumer dispute',
  'Property matter',
  'Employment issue',
  'Banking / loan',
  'Insurance claim',
  'E-commerce refund',
  'Cheque bounce',
  'Landlord dispute',
  'Medical negligence',
  'Cyber fraud',
];

// ── Screen ────────────────────────────────────────────────────────────────────

class CaseAnalysisScreen extends ConsumerStatefulWidget {
  const CaseAnalysisScreen({super.key});

  @override
  ConsumerState<CaseAnalysisScreen> createState() => _CaseAnalysisScreenState();
}

class _CaseAnalysisScreenState extends ConsumerState<CaseAnalysisScreen> {
  final _caseController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _caseController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final text = _caseController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your case first')),
      );
      return;
    }
    if (text.length < 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please provide more details (at least 30 characters)')),
      );
      return;
    }

    _focusNode.unfocus();
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    // Scroll to bottom to show loader
    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }

    try {
      final prompt = '''
Analyze the following legal case under Indian law. The user wants to understand:
1. Strengths of their case
2. Weaknesses or risks
3. Recommended next steps
4. Realistic outcome assessment

Case description:
$text

Provide a thorough legal analysis covering all the above points.
''';

      final result =
          await ref.read(_aiServiceProvider).analyzeProblemFromText(prompt);
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }

    // Scroll to result
    await Future.delayed(const Duration(milliseconds: 150));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  void _reset() {
    setState(() {
      _caseController.clear();
      _result = null;
      _error = null;
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Case Analysis'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Disclaimer ──────────────────────────────
              _DisclaimerBanner(),
              const SizedBox(height: 20),

              // ── Input section ───────────────────────────
              if (_result == null) ...[
                _SectionLabel('DESCRIBE YOUR CASE'),
                const SizedBox(height: 12),

                // Case type chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _caseTypeSuggestions
                      .map((s) => _SuggestionChip(
                            label: s,
                            onTap: () {
                              final current = _caseController.text;
                              if (current.isEmpty) {
                                _caseController.text = '$s — ';
                              } else if (!current.contains(s)) {
                                _caseController.text = '$current, $s';
                              }
                              _caseController.selection =
                                  TextSelection.fromPosition(
                                TextPosition(
                                    offset: _caseController.text.length),
                              );
                              _focusNode.requestFocus();
                            },
                          ))
                      .toList(),
                ),
                const SizedBox(height: 14),

                // Text input
                TextField(
                  controller: _caseController,
                  focusNode: _focusNode,
                  maxLines: 7,
                  maxLength: 1000,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText:
                        'Describe your case in detail...\n\nE.g. I purchased a laptop from Flipkart on 10 Jan 2024. It stopped working after 2 weeks. The seller refused to replace or refund despite warranty.',
                    hintStyle:
                        TextStyle(color: AppColors.textSecondary, height: 1.5),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          BorderSide(color: AppColors.trustBlue, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _analyze,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.track_changes_rounded, size: 20),
                    label: Text(
                      _loading ? 'Analyzing...' : 'Analyze My Case',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],

              // ── Error ───────────────────────────────────
              if (_error != null) ...[
                const SizedBox(height: 20),
                _ErrorCard(onRetry: _analyze),
              ],

              // ── Result ──────────────────────────────────
              if (_result != null) ...[
                // Show original case description collapsed
                _OriginalCaseCard(text: _caseController.text.trim()),
                const SizedBox(height: 20),
                _SectionLabel('CASE ANALYSIS REPORT'),
                const SizedBox(height: 14),
                _CaseAnalysisResult(result: _result!),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _reset,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('New Analysis'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryNavy,
                          side: BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Original Case Card ────────────────────────────────────────────────────────

class _OriginalCaseCard extends StatefulWidget {
  final String text;
  const _OriginalCaseCard({required this.text});

  @override
  State<_OriginalCaseCard> createState() => _OriginalCaseCardState();
}

class _OriginalCaseCardState extends State<_OriginalCaseCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.trustBlue.withValues(alpha: 0.05),
        border: Border.all(color: AppColors.trustBlue.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined,
                  size: 16, color: AppColors.trustBlue),
              const SizedBox(width: 6),
              Text(
                'YOUR CASE',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded ? 'Show less' : 'Show more',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.trustBlue,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.text,
            maxLines: _expanded ? null : 2,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryNavy,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Case Analysis Result ──────────────────────────────────────────────────────

class _CaseAnalysisResult extends StatelessWidget {
  final Map<String, dynamic> result;

  const _CaseAnalysisResult({required this.result});

  String _str(String key) => (result[key] ?? '').toString();

  List<String> _list(String key) {
    final v = result[key];
    if (v is List) return v.map((e) => e.toString()).toList();
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final summary = _str('caseSummary');
    final analysis = _str('legalAnalysis');
    final confidence = result['confidence'];
    final strength = result['legalPosition'] is Map
        ? (result['legalPosition']['strength'] ?? '').toString()
        : '';
    final rights = _list('rights');
    final steps = _list('nextSteps').isNotEmpty
        ? _list('nextSteps')
        : _list('steps');
    final riskFactors = _list('riskFactors');
    final laws = result['relevantLaws'];
    final estimatedOutcome = _str('estimatedOutcome');
    final docsRequired = _list('documents_required');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Confidence + Strength ─────────────────────────
        if (confidence != null || strength.isNotEmpty)
          _InfoBlock(
            icon: Icons.bar_chart_rounded,
            title: 'Case Strength',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (confidence != null) ...[
                  _ConfidenceBar(
                    score: (confidence is num)
                        ? confidence.toInt()
                        : int.tryParse(confidence.toString()) ?? 0,
                  ),
                ],
                if (strength.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _StrengthBadge(strength: strength),
                ],
              ],
            ),
          ),
        if (confidence != null || strength.isNotEmpty) const SizedBox(height: 12),

        // ── Summary ───────────────────────────────────────
        if (summary.isNotEmpty) ...[
          _InfoBlock(
            icon: Icons.summarize_outlined,
            title: 'Case Summary',
            child: Text(summary,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryNavy, height: 1.5)),
          ),
          const SizedBox(height: 12),
        ],

        // ── Strengths (Rights) ────────────────────────────
        if (rights.isNotEmpty) ...[
          _InfoBlock(
            icon: Icons.thumb_up_outlined,
            title: 'Strengths',
            accentColor: const Color(0xFF16A34A),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rights
                  .map((r) => _BulletRow(
                        text: r,
                        color: const Color(0xFF16A34A),
                        icon: Icons.check_circle_outline,
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // ── Risk Factors (Weaknesses) ─────────────────────
        if (riskFactors.isNotEmpty) ...[
          _InfoBlock(
            icon: Icons.warning_amber_outlined,
            title: 'Weaknesses / Risks',
            accentColor: const Color(0xFFDC2626),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: riskFactors
                  .map((r) => _BulletRow(
                        text: r,
                        color: const Color(0xFFDC2626),
                        icon: Icons.error_outline,
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // ── Legal Analysis ────────────────────────────────
        if (analysis.isNotEmpty) ...[
          _InfoBlock(
            icon: Icons.balance_outlined,
            title: 'Legal Analysis',
            child: Text(analysis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryNavy, height: 1.5)),
          ),
          const SizedBox(height: 12),
        ],

        // ── Next Steps ────────────────────────────────────
        if (steps.isNotEmpty) ...[
          _InfoBlock(
            icon: Icons.checklist_rounded,
            title: 'Recommended Next Steps',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: steps.asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primaryNavy,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${e.key + 1}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(e.value,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: AppColors.primaryNavy,
                                    height: 1.4)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // ── Estimated Outcome ─────────────────────────────
        if (estimatedOutcome.isNotEmpty) ...[
          _InfoBlock(
            icon: Icons.flag_outlined,
            title: 'Estimated Outcome',
            child: Text(estimatedOutcome,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryNavy, height: 1.5)),
          ),
          const SizedBox(height: 12),
        ],

        // ── Relevant Laws ─────────────────────────────────
        if (laws is List && laws.isNotEmpty) ...[
          _InfoBlock(
            icon: Icons.menu_book_outlined,
            title: 'Relevant Laws',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: laws.map((l) {
                final lawName = l is Map
                    ? (l['law'] ?? '').toString()
                    : l.toString();
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.legalGold.withValues(alpha: 0.10),
                    border: Border.all(
                        color: AppColors.legalGold.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(lawName,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                              color: AppColors.primaryNavy,
                              fontWeight: FontWeight.w600)),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // ── Documents Required ────────────────────────────
        if (docsRequired.isNotEmpty) ...[
          _InfoBlock(
            icon: Icons.folder_outlined,
            title: 'Documents Required',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: docsRequired
                  .map((d) => _BulletRow(
                        text: d,
                        color: AppColors.trustBlue,
                        icon: Icons.insert_drive_file_outlined,
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // ── Disclaimer ────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.legalGold.withValues(alpha: 0.10),
            border: Border.all(color: AppColors.legalGold),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_rounded,
                  color: AppColors.legalGold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'AI-generated analysis only. Consult a qualified lawyer for legal proceedings.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryNavy, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Strength Badge ────────────────────────────────────────────────────────────

class _StrengthBadge extends StatelessWidget {
  final String strength;
  const _StrengthBadge({required this.strength});

  Color get _color {
    switch (strength.toLowerCase()) {
      case 'strong':
        return const Color(0xFF16A34A);
      case 'moderate':
        return AppColors.legalGold;
      default:
        return const Color(0xFFDC2626);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 14, color: _color),
          const SizedBox(width: 6),
          Text(
            'Case Position: $strength',
            style: TextStyle(
                color: _color,
                fontSize: 12,
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ── Bullet Row ────────────────────────────────────────────────────────────────

class _BulletRow extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;

  const _BulletRow(
      {required this.text, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryNavy, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

// ── Confidence Bar ────────────────────────────────────────────────────────────

class _ConfidenceBar extends StatelessWidget {
  final int score;
  const _ConfidenceBar({required this.score});

  Color get _color {
    if (score >= 70) return const Color(0xFF16A34A);
    if (score >= 40) return AppColors.legalGold;
    return const Color(0xFFDC2626);
  }

  String get _label {
    if (score >= 70) return 'Strong';
    if (score >= 40) return 'Moderate';
    return 'Weak';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$score / 100',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.w700)),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(_label,
                  style: TextStyle(
                      color: _color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(_color),
          ),
        ),
      ],
    );
  }
}

// ── Info Block ────────────────────────────────────────────────────────────────

class _InfoBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Color? accentColor;

  const _InfoBlock({
    required this.icon,
    required this.title,
    required this.child,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.trustBlue;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
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

// ── Error Card ────────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorCard({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        border: Border.all(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Analysis failed. Please check your connection and try again.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.red.shade700),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

// ── Suggestion Chip ───────────────────────────────────────────────────────────

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primaryNavy,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 14, color: AppColors.trustBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.primaryNavy,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
        ),
      ],
    );
  }
}

// ── Disclaimer Banner ─────────────────────────────────────────────────────────

class _DisclaimerBanner extends StatelessWidget {
  const _DisclaimerBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.legalGold.withValues(alpha: 0.10),
        border: Border.all(color: AppColors.legalGold),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.legalGold, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'AI-generated analysis for informational purposes only. Not legal advice.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.primaryNavy, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}