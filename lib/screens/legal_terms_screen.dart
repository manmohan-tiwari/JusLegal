import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juslegal/core/core.dart';
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

const Map<String, _TermResult> _offlineDictionary = {
  'affidavit': _TermResult(
    term: 'Affidavit',
    definition:
        'A written, voluntary statement of facts confirmed by oath or affirmation of the person making it, signed before an authorized officer such as a Notary Public or Oath Commissioner.',
    example:
        'An applicant submits an income affidavit to certify family income for obtaining fee concessions or government schemes.',
    indianContext:
        'Governed under Order 19 of the Code of Civil Procedure (CPC) and the Notaries Act, 1952. Giving false evidence under oath attracts perjury penalties under IPC/BNS.',
  ),
  'anticipatory bail': _TermResult(
    term: 'Anticipatory Bail',
    definition:
        'A pre-arrest direction issued by the Sessions Court or High Court directing that in the event of an arrest for a non-bailable offence, the applicant shall be released on bail.',
    example:
        'A person falsely implicated in a property dispute applies for anticipatory bail to prevent unwarranted police custody.',
    indianContext:
        'Governed under Section 438 of the Code of Criminal Procedure, 1973 (and Section 482 of Bharatiya Nagarik Suraksha Sanhita, 2023).',
  ),
  'caveat': _TermResult(
    term: 'Caveat',
    definition:
        'A formal precautionary notice filed in court by an interested party requesting that no order or judgment be passed in a matter without giving them prior notice and an opportunity to be heard.',
    example:
        'A property owner lodges a caveat in the High Court so that a builder cannot obtain an ex-parte stay order without notifying them.',
    indianContext:
        'Filed under Section 148A of the Code of Civil Procedure, 1908. A caveat remains valid for 90 days from the date of filing.',
  ),
  'contempt of court': _TermResult(
    term: 'Contempt of Court',
    definition:
        'Disobedience to a court order or conduct that disrespects or lowers the dignity and authority of the judicial system.',
    example:
        'A company that refuses to comply with a High Court injunction to stop discharging industrial waste faces contempt proceedings.',
    indianContext:
        'Categorized into Civil and Criminal Contempt under the Contempt of Courts Act, 1971 and Articles 129 and 215 of the Constitution of India.',
  ),
  'decree': _TermResult(
    term: 'Decree',
    definition:
        'The formal and final adjudication by a civil court that conclusively determines the rights of the parties with regard to all or any matters in controversy in a suit.',
    example:
        'The civil court passed a decree for specific performance requiring the seller to execute the sale deed within 30 days.',
    indianContext:
        'Defined under Section 2(2) of the Code of Civil Procedure, 1908. It can be preliminary, final, or partly preliminary and partly final.',
  ),
  'ex parte': _TermResult(
    term: 'Ex Parte',
    definition:
        'A legal proceeding or order made by a court in the presence of one party only, usually when the opposite party fails to appear despite due service of summons.',
    example:
        'When the defendant failed to appear despite three court summons, the court proceeded ex-parte and granted relief to the plaintiff.',
    indianContext:
        'Governed under Order 9 Rule 6 and Order 9 Rule 13 of the Code of Civil Procedure, 1908 for setting aside ex-parte decrees.',
  ),
  'fir': _TermResult(
    term: 'FIR (First Information Report)',
    definition:
        'The earliest information recorded by a police officer about the commission of a cognizable offence, setting the criminal investigation machinery in motion.',
    example:
        'A citizen lodges an FIR at the police station immediately after their car is stolen from outside their residence.',
    indianContext:
        'Registered under Section 154 of CrPC, 1973 (Section 173 of BNSS, 2023). Police cannot refuse registration for cognizable offences (Lalita Kumari ruling).',
  ),
  'habeas corpus': _TermResult(
    term: 'Habeas Corpus',
    definition:
        'A Latin term meaning "you have the body" — a constitutional writ commanding a detaining authority to produce an arrested person in court to verify if detention is lawful.',
    example:
        'Family members file a Habeas Corpus petition in the High Court when a relative is detained by authorities without being produced before a magistrate within 24 hours.',
    indianContext:
        'Issued by the Supreme Court under Article 32 and High Courts under Article 226 of the Constitution of India to safeguard Article 21 rights.',
  ),
  'injunction': _TermResult(
    term: 'Injunction',
    definition:
        'A judicial order restraining a party from doing an unlawful act (prohibitory) or compelling a party to perform a particular positive act (mandatory).',
    example:
        'A neighbour obtains a temporary injunction to stop ongoing unauthorized construction that blocks natural sunlight and access.',
    indianContext:
        'Temporary injunctions are governed under Order 39 of CPC, while perpetual and mandatory injunctions are governed by the Specific Relief Act, 1963.',
  ),
  'jurisdiction': _TermResult(
    term: 'Jurisdiction',
    definition:
        'The official legal authority, power, and territorial or financial boundaries within which a court, tribunal, or magistrate can hear and decide a case.',
    example:
        'A consumer complaint for ₹15 Lakhs falls within the pecuniary jurisdiction of the District Consumer Commission.',
    indianContext:
        'Includes Subject-Matter, Territorial, and Pecuniary jurisdiction under the Code of Civil Procedure, 1908.',
  ),
  'legal notice': _TermResult(
    term: 'Legal Notice',
    definition:
        'A formal written communication drafted by an advocate notifying the recipient of an aggrieved party\'s claims and warning of court action unless remedied within a given timeframe.',
    example:
        'A landlord issues a 15-day legal notice to a tenant demanding unpaid rent arrears before filing an eviction suit.',
    indianContext:
        'Statutory requirement in specific laws like Section 138 of the Negotiable Instruments Act (Cheque bounce) and Section 80 of CPC against the Government.',
  ),
  'lok adalat': _TermResult(
    term: 'Lok Adalat',
    definition:
        'An Alternative Dispute Resolution (ADR) forum where pending court cases or pre-litigation disputes are settled amicably and informally with mutual consent.',
    example:
        'Motor accident claim disputes and electricity bill disputes are frequently settled in National Lok Adalats with full refund of court fees.',
    indianContext:
        'Statutory body constituted under the Legal Services Authorities Act, 1987. An award passed by Lok Adalat is final, binding, and non-appealable.',
  ),
  'mandamus': _TermResult(
    term: 'Mandamus',
    definition:
        'A Latin term meaning "we command" — a high prerogative writ issued by superior courts to compel a public authority or government official to perform their statutory duty.',
    example:
        'A student files a writ of mandamus directing a state university to declare examination results withheld without lawful justification.',
    indianContext:
        'Issued under Article 32 (Supreme Court) and Article 226 (High Courts) against public bodies failing to discharge mandatory statutory obligations.',
  ),
  'pil': _TermResult(
    term: 'PIL (Public Interest Litigation)',
    definition:
        'A legal action initiated before the Supreme Court or High Court for the enforcement of public interest and protection of fundamental rights of disadvantaged groups.',
    example:
        'An environmental group files a PIL in the High Court to halt illegal industrial waste dumping in a municipal river.',
    indianContext:
        'Pioneered by Justice P.N. Bhagwati and Justice V.R. Krishna Iyer; relaxed rules of locus standi under Articles 32 and 226 of the Constitution.',
  ),
  'power of attorney': _TermResult(
    term: 'Power of Attorney (PoA)',
    definition:
        'A formal legal instrument executed by a principal authorizing another person (attorney/agent) to act and sign on their behalf in financial, legal, or property affairs.',
    example:
        'An NRI living in Dubai executes a General Power of Attorney to let their brother manage and rent out ancestral property in Delhi.',
    indianContext:
        'Governed by the Powers of Attorney Act, 1882. Property conveyance via PoA alone does not confer ownership title (Suraj Lamp judgment).',
  ),
  'stay order': _TermResult(
    term: 'Stay Order',
    definition:
        'An interim judicial directive that temporarily stops the implementation, enforcement, or continuation of an order, decree, demolition, or proceedings.',
    example:
        'A homeowner obtains an interim stay order against a municipal demolition notice until the court hears the legality of the building plan.',
    indianContext:
        'Granted under Order 39 of CPC or Section 151 (inherent powers) and writ jurisdiction under Article 226 of the Constitution of India.',
  ),
  'suo motu': _TermResult(
    term: 'Suo Motu',
    definition:
        'A Latin term meaning "on its own motion" — refers to instances where a court or commission initiates legal proceedings on its own initiative without a formal petition.',
    example:
        'The High Court takes suo motu cognizance of severe hospital oxygen shortages during a public health crisis based on newspaper reports.',
    indianContext:
        'Commonly exercised by High Courts, the Supreme Court, the National Human Rights Commission (NHRC), and the National Green Tribunal (NGT).',
  ),
  'vakalatnama': _TermResult(
    term: 'Vakalatnama',
    definition:
        'A written memorandum and authorization letter appointing an advocate or pleader to appear, plead, and act on behalf of a litigant before a court of law.',
    example:
        'A petitioner signs a Vakalatnama authorizing their senior counsel to represent them in the District Court trial.',
    indianContext:
        'Governed under Order 3 of the Code of Civil Procedure, 1908 and the Advocates Act, 1961. Requires appropriate court fee and welfare stamp.',
  ),
  'writ petition': _TermResult(
    term: 'Writ Petition',
    definition:
        'A formal written petition filed before the Supreme Court or High Court seeking an extraordinary judicial remedy for the violation of constitutional or fundamental rights.',
    example:
        'A citizen files a writ petition under Article 226 challenging arbitrary cancellation of a commercial license without notice.',
    indianContext:
        'Filed under Article 32 (Supreme Court) or Article 226 (High Court). Five primary types: Habeas Corpus, Mandamus, Prohibition, Certiorari, and Quo Warranto.',
  ),
  'consumer forum': _TermResult(
    term: 'Consumer Forum (Consumer Commission)',
    definition:
        'Specialized quasi-judicial bodies established to protect consumer rights and provide speedy, cost-effective redressal for defective goods and deficiency in services.',
    example:
        'A customer files a case in the District Consumer Commission against an airline for lost baggage compensation.',
    indianContext:
        'Three-tier structure (District, State, and National) under the Consumer Protection Act, 2019 with e-filing via e-Daakhil portal.',
  ),
};

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

    // Check offline dictionary first for instant response
    final normalized = trimmed.toLowerCase();
    if (_offlineDictionary.containsKey(normalized)) {
      setState(() {
        _loading = false;
        _error = null;
        _result = _offlineDictionary[normalized];
        _searchedTerm = trimmed;
      });
      return;
    }

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
              : 'Detailed Indian legal analysis provided below.',
          example: steps.isNotEmpty ? steps.first.toString() : '',
          indianContext: legalAnalysis.isNotEmpty
              ? legalAnalysis
              : 'Governed under relevant Indian statutory enactments and judicial precedents.',
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
                          backgroundColor: AppColors.legalGold,
                          foregroundColor: const Color(0xFF0B0F19),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Search',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0B0F19),
                            )),
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
                      foregroundColor: AppColors.legalGold,
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
