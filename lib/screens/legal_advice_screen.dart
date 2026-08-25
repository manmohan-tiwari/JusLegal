import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/theme_config.dart';
import '../services/ai_service.dart';

class _QTemplate {
  final String display;
  final String prompt;
  final String hint;
  final IconData icon;

  const _QTemplate({
    required this.display,
    required this.prompt,
    required this.hint,
    required this.icon,
  });
}

const List<_QTemplate> _templates = [
  _QTemplate(
    display: 'What legal steps should I take after an incident?',
    prompt:
        'What legal steps should I take after the following incident: {input}? Explain under Indian law.',
    hint: 'Describe the incident (e.g. product damaged during delivery)',
    icon: Icons.directions_walk_outlined,
  ),
  _QTemplate(
    display: 'Should I file a lawsuit for this issue?',
    prompt:
        'Should I file a lawsuit for the following issue under Indian consumer law: {input}? Give pros, cons and recommendation.',
    hint: 'Describe the issue (e.g. seller refused refund for defective item)',
    icon: Icons.gavel_outlined,
  ),
  _QTemplate(
    display: 'How can I protect myself legally in this scenario?',
    prompt:
        'How can I protect myself legally in the following scenario under Indian law: {input}?',
    hint:
        'Describe the scenario (e.g. landlord not returning security deposit)',
    icon: Icons.shield_outlined,
  ),
  _QTemplate(
    display: 'Is it advisable to sign a contract with this clause?',
    prompt:
        'Is it advisable to sign a contract that includes the following clause under Indian contract law: {input}? Explain risks.',
    hint: 'Paste or describe the clause',
    icon: Icons.edit_document,
  ),
  _QTemplate(
    display: 'What are my legal options if this situation occurs?',
    prompt:
        'What are my legal options if the following situation occurs under Indian law: {input}?',
    hint: 'Describe the situation (e.g. employer withheld salary)',
    icon: Icons.account_tree_outlined,
  ),
  _QTemplate(
    display: 'What legal risks are involved in this action?',
    prompt:
        'What legal risks are involved in the following action under Indian law: {input}?',
    hint: 'Describe the action (e.g. starting a food business from home)',
    icon: Icons.warning_amber_outlined,
  ),
  _QTemplate(
    display: 'Can I represent myself in this type of case?',
    prompt:
        'Can I represent myself in the following type of case in Indian courts: {input}? What are the practical implications?',
    hint:
        'Describe the case type (e.g. consumer court complaint under Rs.20 lakh)',
    icon: Icons.person_outlined,
  ),
  _QTemplate(
    display: 'Should I settle or go to trial for this dispute?',
    prompt:
        'Should I settle or go to trial for the following dispute under Indian law: {input}? Give a balanced analysis.',
    hint: 'Describe the dispute (e.g. builder delayed possession by 2 years)',
    icon: Icons.balance_outlined,
  ),
  _QTemplate(
    display: 'What kind of lawyer should I hire for this case?',
    prompt:
        'What kind of lawyer should I hire for the following case in India: {input}? Describe the specialisation needed.',
    hint: 'Describe the case (e.g. cheque bounce / NI Act case)',
    icon: Icons.support_agent_outlined,
  ),
  _QTemplate(
    display: 'How can I appeal a decision related to this case?',
    prompt:
        'How can I appeal a decision related to the following case under Indian law: {input}? Explain the appeal process step by step.',
    hint:
        'Describe the case and decision (e.g. consumer forum ruled against me)',
    icon: Icons.upload_outlined,
  ),
];

final _aiServiceProvider = Provider<AIService>((ref) {
  final svc = AIService();
  svc.initialize();
  return svc;
});

class LegalAdviceScreen extends ConsumerStatefulWidget {
  const LegalAdviceScreen({super.key});

  @override
  ConsumerState<LegalAdviceScreen> createState() => _LegalAdviceScreenState();
}

class _LegalAdviceScreenState extends ConsumerState<LegalAdviceScreen> {
  _QTemplate? _selected;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final input = _controller.text.trim();
    final selected = _selected;
    if (selected == null || input.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }

    try {
      final prompt = selected.prompt.replaceFirst('{input}', input);
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
      _selected = null;
      _result = null;
      _error = null;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text('Legal Advice Q&A'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DisclaimerBanner(),
              const SizedBox(height: 20),
              _SectionLabel(
                selected == null ? 'SELECT A QUESTION' : 'SELECTED QUESTION',
              ),
              const SizedBox(height: 12),
              if (selected == null) ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _templates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _QuestionTile(
                    template: _templates[i],
                    onTap: () => setState(() {
                      _selected = _templates[i];
                      _result = null;
                      _error = null;
                      _controller.clear();
                    }),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Color(0xFF0052CC).withValues(alpha: 0.07),
                    border: Border.all(
                        color: Color(0xFF0052CC).withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(selected.icon, color: Color(0xFF0052CC), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          selected.display,
                          style: const TextStyle(
                            color: Color(0xFF1F2937),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _reset,
                        child: const Text('Change'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionLabel('YOUR DETAILS'),
                const SizedBox(height: 10),
                TextField(
                  controller: _controller,
                  maxLines: 4,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: selected.hint,
                    hintStyle: TextStyle(color: Color(0xFF6B7280)),
                    filled: true,
                    fillColor: Color(0xFFFFFFFF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          BorderSide(color: Color(0xFF0052CC), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1F2937),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Get Legal Advice',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    border: Border.all(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Something went wrong. Please try again.',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _submit,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ],
              if (_result != null) ...[
                const SizedBox(height: 24),
                Text(
                  'AI ANALYSIS',
                  style: const TextStyle(
                    color: Color(0xFF0052CC),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                _ResultCard(result: _result!),
                const SizedBox(height: 16),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Ask Another Question'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFF1F2937),
                      side: BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionTile extends StatelessWidget {
  final _QTemplate template;
  final VoidCallback onTap;

  const _QuestionTile({required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.trustBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(template.icon, color: AppTheme.trustBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  template.display,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryNavy,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF9CA3AF), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> result;

  const _ResultCard({required this.result});

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
    final rights = _list('rights');
    final steps =
        _list('nextSteps').isNotEmpty ? _list('nextSteps') : _list('steps');
    final laws = result['relevantLaws'];
    final confidence = result['confidence'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (summary.isNotEmpty)
          _InfoBlock(
            icon: Icons.summarize_outlined,
            title: 'Summary',
            child: Text(summary,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.primaryNavy, height: 1.5)),
          ),
        if (summary.isNotEmpty) const SizedBox(height: 12),
        if (confidence != null)
          _InfoBlock(
            icon: Icons.bar_chart_rounded,
            title: 'Case Strength',
            child: _ConfidenceBar(
                score: (confidence is num)
                    ? confidence.toInt()
                    : int.tryParse(confidence.toString()) ?? 0),
          ),
        if (confidence != null) const SizedBox(height: 12),
        if (analysis.isNotEmpty)
          _InfoBlock(
            icon: Icons.balance_outlined,
            title: 'Legal Analysis',
            child: Text(analysis,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.primaryNavy, height: 1.5)),
          ),
        if (analysis.isNotEmpty) const SizedBox(height: 12),
        if (rights.isNotEmpty)
          _InfoBlock(
            icon: Icons.verified_outlined,
            title: 'Your Rights',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rights
                  .map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline,
                                size: 16, color: Color(0xFF16A34A)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(r,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: AppTheme.primaryNavy,
                                          height: 1.4)),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        if (rights.isNotEmpty) const SizedBox(height: 12),
        if (steps.isNotEmpty)
          _InfoBlock(
            icon: Icons.checklist_rounded,
            title: 'Next Steps',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: steps.asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppTheme.trustBlue.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${e.key + 1}',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.trustBlue),
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
                                    color: AppTheme.primaryNavy, height: 1.4)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        if (steps.isNotEmpty) const SizedBox(height: 12),
        if (laws is List && laws.isNotEmpty)
          _InfoBlock(
            icon: Icons.menu_book_outlined,
            title: 'Relevant Laws',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: laws.map((l) {
                final lawName =
                    l is Map ? (l['law'] ?? '').toString() : l.toString();
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.legalGold.withValues(alpha: 0.10),
                    border: Border.all(
                        color: AppTheme.legalGold.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(lawName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.primaryNavy,
                          fontWeight: FontWeight.w600)),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.legalGold.withValues(alpha: 0.10),
            border: Border.all(color: AppTheme.legalGold),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_rounded,
                  color: AppTheme.legalGold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'AI-generated guidance only. Not a substitute for professional legal advice.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppTheme.primaryNavy, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _InfoBlock(
      {required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.trustBlue),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.primaryNavy,
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

class _ConfidenceBar extends StatelessWidget {
  final int score;

  const _ConfidenceBar({required this.score});

  Color get _color {
    if (score >= 70) return const Color(0xFF16A34A);
    if (score >= 40) return AppTheme.legalGold;
    return Colors.red;
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
                    color: AppTheme.primaryNavy, fontWeight: FontWeight.w700)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
            backgroundColor: AppTheme.border,
            valueColor: AlwaysStoppedAnimation<Color>(_color),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 14, color: AppTheme.trustBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ).copyWith(color: AppTheme.primaryNavy),
        ),
      ],
    );
  }
}

class _DisclaimerBanner extends StatelessWidget {
  const _DisclaimerBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.legalGold.withValues(alpha: 0.10),
        border: Border.all(color: AppTheme.legalGold),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppTheme.legalGold, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This AI tool provides general information based on Indian law. It is NOT a substitute for professional legal advice from a qualified lawyer.',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ).copyWith(
                color: AppTheme.primaryNavy.withValues(alpha: 0.7),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
