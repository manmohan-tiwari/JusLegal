import 'package:flutter/material.dart';
import '../../core/config/theme_config.dart';
import '../../models/form_template_model.dart';
import 'document_type_chip.dart';


class FormCategorySection extends StatefulWidget {
  final String categoryLabel;
  final IconData icon;
  final List<FormTemplateModel> forms;
  final ValueChanged<FormTemplateModel> onFormSelected;
  final bool initiallyExpanded;

  const FormCategorySection({
    super.key,
    required this.categoryLabel,
    required this.icon,
    required this.forms,
    required this.onFormSelected,
    this.initiallyExpanded = true,
  });

  @override
  State<FormCategorySection> createState() => _FormCategorySectionState();
}

class _FormCategorySectionState extends State<FormCategorySection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(14),
              bottom: _expanded ? Radius.zero : const Radius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.trustBlue.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon,
                        color: AppColors.trustBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.categoryLabel,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                            color: AppColors.primaryNavy,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  Text(
                    '${widget.forms.length} forms',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.forms
                    .map((form) => DocumentTypeChip(
                          label: form.title,
                          onTap: () => widget.onFormSelected(form),
                        ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
