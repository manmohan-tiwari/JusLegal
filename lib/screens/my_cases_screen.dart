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
import '../widgets/hover_stay_reveal_box.dart';

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
      backgroundColor: AppColors.warmOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.warmOffWhite,
        foregroundColor: AppColors.deepNavy,
        iconTheme: const IconThemeData(color: AppColors.deepNavy),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.divider,
            height: 1,
          ),
        ),
        title: Text(
          'My Cases',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.deepNavy,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                style: const TextStyle(color: AppColors.deepNavy, fontSize: 14.5),
                decoration: InputDecoration(
                  hintText: 'Search cases by topic or keywords...',
                  hintStyle: const TextStyle(color: AppColors.slateBlue, fontSize: 13.5),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.slateBlue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.deepNavy, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      label: Text(
                        status,
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.deepNavy,
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      selected: selected,
                      selectedColor: AppColors.deepNavy,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: selected ? AppColors.deepNavy : AppColors.outline,
                        ),
                      ),
                      showCheckmark: false,
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "${filtered.length} case${filtered.length == 1 ? '' : 's'} found",
                  style: const TextStyle(
                    color: AppColors.slateBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
              color: AppColors.error,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
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
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return shouldDelete ?? false;
  }

  void _showResolvedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.deepNavy,
        duration: Duration(seconds: 2),
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.mustardGold),
            SizedBox(width: 8),
            Text(
              'Case marked as resolved',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
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

  ({Color bg, Color text, Color border}) _statusMeta(String status) {
    switch (status) {
      case 'Resolved':
        return (
          bg: AppColors.paleGreen,
          text: const Color(0xFF1E5624),
          border: const Color(0xFFC7E2CA),
        );
      case 'Pending':
        return (
          bg: AppColors.paleYellow,
          text: const Color(0xFF8C5B00),
          border: const Color(0xFFF3DE9C),
        );
      default:
        return (
          bg: AppColors.paleBlue,
          text: AppColors.deepNavy,
          border: const Color(0xFFD4E2EC),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final meta = _statusMeta(item.status);
    final radius = BorderRadius.circular(14);

    return HoverStayRevealBox(
      onTap: onOpen,
      borderRadius: radius,
      builder: (context, isRevealed) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
            border: Border.all(
              color: isRevealed
                  ? AppColors.deepNavy.withValues(alpha: 0.35)
                  : AppColors.outline,
              width: isRevealed ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isRevealed
                    ? AppColors.deepNavy.withValues(alpha: 0.1)
                    : const Color(0x06162B49),
                blurRadius: isRevealed ? 12 : 8,
                offset: Offset(0, isRevealed ? 4 : 2),
              ),
            ],
          ),
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
                        Text(
                          item.category,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                color: AppColors.deepNavy,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMM yyyy').format(item.date),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppColors.slateBlue,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: meta.bg,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: meta.border),
                    ),
                    child: Text(
                      item.status,
                      style: TextStyle(
                        color: meta.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              HoverRevealContent(
                isRevealed: isRevealed,
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  item.problemSnippet,
                  style: const TextStyle(
                    color: AppColors.deepNavy,
                    fontSize: 13.5,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              if (onMarkResolved != null) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onMarkResolved,
                    icon: const Icon(Icons.check_circle_outline,
                        size: 16, color: AppColors.slateBlue),
                    label: const Text(
                      'Mark resolved',
                      style: TextStyle(
                        color: AppColors.deepNavy,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
