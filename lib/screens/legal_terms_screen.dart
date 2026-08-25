import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/theme_config.dart';
import '../services/ai_service.dart';
import '../widgets/section_label.dart';

final _aiServiceProvider = Provider<AIService>((ref) {
  final svc = AIService();
  svc.initialize();
  return svc;
});

const List<String> _popularTerms = [
  'Affidavit',
  'Anticipatory Bail',
  'Caveat',
  'Contempt of Court',
  'Decree',
  'Ex Parte',
  'FIR',
  'Habeas Corpus',
  'Injunction',
  'Jurisdiction',
  'Legal Notice',
  'Lok Adalat',
  'Mandamus',
  'PIL',
  'Power of Attorney',
  'Stay Order',
  'Suo Motu',
  'Vakalatnama',
  'Writ Petition',
  'Consumer Forum',
];

class _TermResult {
  final String term;
  final String definition;
  final String example;
  final String indianContext;

  const _TermResult({
    required this.term,
    required this.definition,
    required this.example,
    required this.indianContext,
  });
}

class LegalTermsScreen extends ConsumerStatefulWidget {
  const LegalTermsScreen({super.key});

  @override
  ConsumerState<LegalTermsScreen> createState() => _LegalTermsScreenState();
}

class _LegalTermsScreenState extends ConsumerState<LegalTermsScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  bool _loading = false;
  String? _error;
  _TermResult? _result;
  String _searchedTerm = '';

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _search(String term) async {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return;

    _focusNode.unfocus();
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
      _searchedTerm = trimmed;
    });

    final prompt = '''
You are an Indian legal dictionary. Explain the legal term "$trimmed" in the context of Indian law.

Respond ONLY in this exact JSON format, no markdown, no extra text:
{
  "definition": "Clear plain-English definition in 2-3 sentences",
  "example": "A practical real-world example of how this term is used in India (1-2 sentences)",
  "indianContext": "How this term specifically applies under Indian law, which Act or Court uses it (1-2 sentences)"
}

If the term is not a legal term, return:
{
  "definition": "This does not appear to be a recognised legal term.",
  "example": "",
  "indianContext": ""
}
''';

    try {
      final raw =
          await ref.read(_aiServiceProvider).analyzeProblemFromText(prompt);

      final caseSummary = (raw['caseSummary'] ?? '').toString();
      final legalAnalysis = (raw['legalAnalysis'] ?? '').toString();
      final steps = raw['nextSteps'] is List ? raw['nextSteps'] as List : [];

      setState(() {
        _result = _TermResult(
          term: trimmed,
          definition: caseSummary.isNotEmpty
              ? caseSummary
              : 'See legal analysis below.',
          example: steps.isNotEmpty ? steps.first.toString() : '',
          indianContext: legalAnalysis,
        );
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _clear() {
    setState(() {
      _searchController.clear();
      _result = null;
      _error = null;
      _searchedTerm = '';
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final showPopularTerms = result == null && !_loading && _error == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Legal Terms Dictionary'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryNavy.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Icon(Icons.search_rounded,
                        color: Color(0xFF9CA3AF), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.search,
                        onSubmitted: _search,
                        decoration: const InputDecoration(
                          hintText: 'Search a legal term...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 20, color: Color(0xFF9CA3AF)),
                        onPressed: _clear,
                      ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ElevatedButton(
                        onPressed: _loading
                            ? null
                            : () => _search(_searchController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryNavy,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Search',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (showPopularTerms) ...[
                SectionLabel('POPULAR TERMS'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _popularTerms
                      .map((term) => _TermChip(
                            label: term,
                            onTap: () {
                              _searchController.text = term;
                              _search(term);
                            },
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
                _DisclaimerBanner(),
              ],
              if (_loading) ...[
                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Looking up "$_searchedTerm"...',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
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
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.red.shade700),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _search(_searchedTerm),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ],
              if (result != null) ...[
                _TermResultCard(
                  result: result,
                  onSearchRelated: (term) {
                    _searchController.text = term;
                    _search(term);
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: _clear,
                    icon: const Icon(Icons.search_rounded, size: 18),
                    label: const Text('Search Another Term'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryNavy,
                      side: const BorderSide(color: AppColors.border),
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

class _TermResultCard extends StatelessWidget {
  final _TermResult result;
  final ValueChanged<String> onSearchRelated;

  const _TermResultCard({required this.result, required this.onSearchRelated});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryNavy, AppColors.trustBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.menu_book_outlined,
                  color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.term,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Legal Term - Indian Law',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.75)),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_outlined,
                    color: Colors.white, size: 20),
                tooltip: 'Copy definition',
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                    text:
                        '${result.term}\n\n${result.definition}\n\n${result.indianContext}',
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Definition copied to clipboard')),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _InfoBlock(
          icon: Icons.info_outline_rounded,
          title: 'Definition',
          child: Text(
            result.definition,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.primaryNavy, height: 1.6),
          ),
        ),
        if (result.indianContext.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InfoBlock(
            icon: Icons.account_balance_outlined,
            title: 'Under Indian Law',
            child: Text(
              result.indianContext,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.primaryNavy, height: 1.6),
            ),
          ),
        ],
        if (result.example.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InfoBlock(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Example',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.trustBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.trustBlue.withValues(alpha: 0.2)),
              ),
              child: Text(
                result.example,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryNavy,
                    height: 1.6,
                    fontStyle: FontStyle.italic),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        _DisclaimerBanner(),
      ],
    );
  }
}

class _TermChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TermChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_outlined,
                size: 14, color: AppColors.trustBlue),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
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
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.trustBlue),
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
              'Definitions are AI-generated for educational purposes. Not legal advice.',
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
