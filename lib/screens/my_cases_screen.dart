import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:juslegal/core/core.dart';
import '../models/legal_result_model.dart';
import '../models/saved_case_model.dart';
import '../providers/ai_provider.dart';
import '../providers/cases_provider.dart';
import '../widgets/empty_state_widget.dart';

class MyCasesScreen extends ConsumerStatefulWidget {
  const MyCasesScreen({super.key});

  @override
  ConsumerState<MyCasesScreen> createState() => _MyCasesScreenState();
}

class _MyCasesScreenState extends ConsumerState<MyCasesScreen> {
  String _filter = 'All';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final cases = ref.watch(casesProvider);
    final lowerQuery = _query.toLowerCase();
    final filtered = cases.where((item) {
      final matchesFilter = _filter == 'All' || item.status == _filter;
      final matchesQuery = lowerQuery.isEmpty ||
          item.category.toLowerCase().contains(lowerQuery) ||
          item.problemSnippet.toLowerCase().contains(lowerQuery);
      return matchesFilter && matchesQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cases'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Search cases',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                children:
                    ['All', 'Active', 'Resolved', 'Pending'].map((status) {
                  final selected = _filter == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: selected,
                      onSelected: (value) {
                        if (value) {
                          setState(() => _filter = status);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "${filtered.length} case${filtered.length == 1 ? '' : 's'} found",
                  style: const TextStyle(
                    color: AppTheme.mediumText,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Expanded(child: _buildCasesContent(context, cases, filtered)),
          ],
        ),
      ),
    );
  }

  Widget _buildCasesContent(
    BuildContext context,
    List<SavedCaseModel> cases,
    List<SavedCaseModel> filtered,
  ) {
    if (cases.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.folder_open_outlined,
        title: 'No cases yet',
        subtitle: 'Analyse your first problem to see it here',
        actionLabel: 'Start Analysis',
        onActionPressed: () => context.go('/analyze'),
      );
    }

    if (filtered.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.search_off_outlined,
        title: 'No cases found',
        subtitle: 'Try a different search or filter.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final caseItem = filtered[index];
        return Dismissible(
          key: Key(caseItem.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppTheme.error,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.delete_outline, color: AppTheme.surface),
          ),
          confirmDismiss: (_) => _confirmDelete(context),
          onDismissed: (_) =>
              ref.read(casesProvider.notifier).remove(caseItem.id),
          child: _CaseCard(
            item: caseItem,
            onOpen: () {
              ref.read(lastResultProvider.notifier).set(
                    LegalResultModel.fromJson(caseItem.resultJson),
                  );
              context.go('/home/result');
            },
            onMarkResolved: caseItem.status == 'Resolved'
                ? null
                : () {
                    ref.read(casesProvider.notifier).markResolved(caseItem.id);
                    _showResolvedSnackBar();
                  },
          ),
        );
      },
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this case?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return shouldDelete ?? false;
  }

  void _showResolvedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.success,
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: AppTheme.surface),
            const SizedBox(width: 8),
            const Text(
              'Case marked as resolved',
              style: TextStyle(
                color: AppTheme.surface,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaseCard extends StatelessWidget {
  final SavedCaseModel item;
  final VoidCallback onOpen;
  final VoidCallback? onMarkResolved;

  const _CaseCard({
    required this.item,
    required this.onOpen,
    required this.onMarkResolved,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'Resolved':
        return AppTheme.success;
      case 'Pending':
        return AppTheme.legalGold;
      default:
        return AppTheme.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(item.status);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(
                color: statusColor,
                width: 4,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.category,
                              style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMM yyyy').format(item.date),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.mediumText,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: statusColor.withValues(alpha: 0.35)),
                      ),
                      child: Text(
                        item.status,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: statusColor,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.problemSnippet,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.mediumText,
                        height: 1.45,
                      ),
                ),
                if (onMarkResolved != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onMarkResolved,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Mark resolved'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
