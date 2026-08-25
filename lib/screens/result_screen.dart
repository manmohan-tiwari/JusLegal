import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/config/theme_config.dart';
import '../models/legal_result_model.dart';
import '../models/saved_case_model.dart';

import '../providers/ai_provider.dart';
import '../providers/cases_provider.dart';
import '../providers/problem_provider.dart';
import '../widgets/authority_card.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/step_card.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final LegalResultModel? initialResult;

  const ResultScreen({super.key, this.initialResult});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  ({Color color, String label}) _confidenceMeta(int confidence) {
    if (confidence > 70) return (color: AppTheme.success, label: 'Strong case');
    if (confidence >= 40) return (color: AppTheme.legalGold, label: 'Moderate');
    return (color: AppTheme.error, label: 'Weak');
  }

  Widget _maybeTruncatedLawChip(String text) {
    final isTruncated = text.length > 30;
    final displayText = isTruncated ? '${text.substring(0, 27)}...' : text;
    final chip = Chip(label: Text(displayText));

    if (!isTruncated) return chip;
    return Tooltip(message: text, child: chip);
  }

  void _share(LegalResultModel result) {
    final text = StringBuffer()
      ..writeln('JusLegal Analysis for ${result.category}')
      ..writeln()
      ..writeln('Legal Analysis: ${result.lawSummary}')
      ..writeln('Relevant Law: ${result.applicableLaw}')
      ..writeln()
      ..writeln('Next Steps:')
      ..writeln(result.steps
          .asMap()
          .entries
          .map((entry) => '${entry.key + 1}. ${entry.value}')
          .join('\n'));

    Share.share(text.toString());
  }

  Future<void> _saveCase(
      BuildContext context, WidgetRef ref, LegalResultModel result) async {
    final problem = ref.read(problemProvider);

    final caseModel = SavedCaseModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: result.category,
      problemSnippet: problem.description.length > 100
          ? '${problem.description.substring(0, 97)}...'
          : problem.description,
      date: DateTime.now(),
      status: 'Active',
      resultJson: result.toJson(),
    );

    try {
      await ref.read(casesProvider.notifier).add(caseModel);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.success,
            duration: const Duration(seconds: 2),
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'Case saved to My Cases',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unable to save case. Please try again.'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _generateComplaint(BuildContext context) {
    context.push('/home/complaint');
  }

  Future<void> _launchAuthorityWebsite(String website) async {
    final cleaned = website.trim();
    if (cleaned.isEmpty ||
        cleaned.contains('@') ||
        RegExp(r'^\d').hasMatch(cleaned)) {
      return;
    }
    final uri =
        Uri.parse(cleaned.startsWith('http') ? cleaned : 'https://$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final analysisAsync = ref.watch(analysisProvider);
    final fallbackResult =
        widget.initialResult ?? ref.watch(lastResultProvider);

    return analysisAsync.when(
      data: (state) {
        final result = fallbackResult ?? state.result?.value;
        if (result == null) {
          return _buildNoAnalysisScreen(context);
        }
        return _buildResultScreen(context, ref, result);
      },
      loading: () {
        if (fallbackResult != null) {
          return _buildResultScreen(context, ref, fallbackResult,
              isRefreshing: true);
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Your Legal Analysis')),
          body: const ShimmerLoader(),
        );
      },
      error: (error, _) {
        if (fallbackResult != null) {
          return _buildResultScreen(context, ref, fallbackResult,
              errorMessage: error.toString());
        }
        return _buildErrorScreen(context, ref, error.toString());
      },
    );
  }

  Widget _buildNoAnalysisScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Legal Analysis')),
      body: Center(
        child: Text(
          'No analysis available',
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(
      BuildContext context, WidgetRef ref, String errorMessage) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Legal Analysis')),
      body: Center(
        child: Card(
          color: AppTheme.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppTheme.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppTheme.error,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'Something went wrong',
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref.invalidate(analysisProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen(
    BuildContext context,
    WidgetRef ref,
    LegalResultModel result, {
    bool isRefreshing = false,
    String? errorMessage,
  }) {
    final canGenerateComplaint = result.steps.isNotEmpty;
    final generateComplaintButton = ElevatedButton(
      onPressed: canGenerateComplaint
          ? () {
              HapticFeedback.lightImpact();
              _generateComplaint(context);
            }
          : null,
      child: const Text('Generate Complaint'),
    );
    final generateComplaintButtonWithState = canGenerateComplaint
        ? generateComplaintButton
        : Tooltip(
            message: 'Analysis incomplete',
            child: AbsorbPointer(child: generateComplaintButton),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Legal Analysis'),
        actions: [
          IconButton(
            onPressed: () => _share(result),
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          if (isRefreshing || errorMessage != null)
            Container(
              width: double.infinity,
              color: errorMessage != null ? AppTheme.error : AppTheme.surface,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    errorMessage != null ? Icons.error_outline : Icons.refresh,
                    color: errorMessage != null
                        ? Colors.white
                        : AppTheme.primaryNavy,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage ?? 'Updating analysis...',
                      style: TextStyle(
                        color: errorMessage != null
                            ? Colors.white
                            : AppTheme.primaryNavy,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (errorMessage != null)
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ref.invalidate(analysisProvider);
                      },
                      child: const Text('Retry'),
                    ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConfidenceScore(Theme.of(context), result.confidence),
                  const SizedBox(height: 24),
                  _ReportCard(
                    title: 'Your Rights',
                    icon: Icons.gavel_rounded,
                    child: _buildRightsContent(Theme.of(context), result),
                  ),
                  const SizedBox(height: 16),
                  _ReportCard(
                    title: 'Recommended Steps',
                    icon: Icons.checklist_rtl_rounded,
                    child: _buildStepsContent(result),
                  ),
                  const SizedBox(height: 16),
                  _ReportCard(
                    title: 'Relevant Laws',
                    icon: Icons.menu_book_rounded,
                    child: _buildLawsContent(result),
                  ),
                  const SizedBox(height: 16),
                  _ReportCard(
                    title: 'Authorities to Contact',
                    icon: Icons.account_balance_rounded,
                    child: _buildAuthoritiesContent(result),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            decoration: const BoxDecoration(
              color: AppTheme.background,
              border: Border(top: BorderSide(color: AppTheme.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _saveCase(context, ref, result);
                    },
                    child: const Text('Save Case'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: generateComplaintButtonWithState,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceScore(ThemeData theme, int confidence) {
    final meta = _confidenceMeta(confidence);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Confidence Score',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$confidence%',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: meta.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      meta.label,
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: meta.color),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: confidence / 100,
            backgroundColor: AppTheme.border,
            color: meta.color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildRightsContent(ThemeData theme, LegalResultModel result) {
    final rights = result.rightsAvailable;
    if (rights != null && rights.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rights
            .map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('- ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Text(
                          r,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.primaryNavy),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      );
    }

    return Text(
      result.userRights,
      style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.primaryNavy),
    );
  }

  Widget _buildStepsContent(LegalResultModel result) {
    final steps = result.steps;
    return Column(
      children: steps.asMap().entries.map((entry) {
        final isLast = entry.key == steps.length - 1;
        return DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppTheme.border)),
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
            child: StepCard(
              index: entry.key,
              text: entry.value,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLawsContent(LegalResultModel result) {
    final laws = result.relevantLaws;
    final chips = laws != null && laws.isNotEmpty
        ? laws.map((law) {
            final text = (law['law'] ?? law['section'] ?? '').toString();
            return _maybeTruncatedLawChip(text);
          }).toList()
        : [
            _maybeTruncatedLawChip(
              result.applicableLaw.isNotEmpty
                  ? result.applicableLaw
                  : 'Unknown',
            ),
          ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }

  Widget _buildAuthoritiesContent(LegalResultModel result) {
    if ((result.authoritiesDetailed ?? []).isEmpty &&
        result.authorities.isEmpty) {
      return const Text('No authorities listed for this case.');
    }
    return Column(
      children:
          (result.authoritiesDetailed ?? result.authorities).map((authority) {
        final map = Map<String, String>.from(authority as Map);
        final website = map['official_website'] ??
            map['officialWebsite'] ??
            map['website'] ??
            map['contact'] ??
            '';
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AuthorityCard(
            name: map['name'] ?? 'Authority',
            purpose: map['description'] ??
                map['purpose'] ??
                map['why_relevant'] ??
                map['action'],
            action: website.isNotEmpty ? 'Visit Website' : 'Learn More',
            onAction: website.isNotEmpty
                ? () => _launchAuthorityWebsite(website)
                : () {},
          ),
        );
      }).toList(),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _ReportCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.background,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.trustBlue, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}
