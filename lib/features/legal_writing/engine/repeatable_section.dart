import 'package:flutter/material.dart';
import 'package:juslegal/core/core.dart';
import '../models/form_section_definition.dart';
import 'section_renderer.dart';

typedef OnRepeatableItemChanged = void Function(
    String sectionId, int index, String fieldId, dynamic value);
typedef OnRepeatableAction = void Function(String sectionId, int? index);

class RepeatableSectionRenderer extends StatelessWidget {
  final RepeatableSectionDefinition section;
  final List<Map<String, dynamic>> items;
  final Map<String, String> errors;
  final OnRepeatableItemChanged onItemChanged;
  final OnRepeatableAction onAddItem;
  final OnRepeatableAction onRemoveItem;

  const RepeatableSectionRenderer({
    super.key,
    required this.section,
    required this.items,
    required this.errors,
    required this.onItemChanged,
    required this.onAddItem,
    required this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14, top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
              ),
              if (section.description != null) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 11),
                  child: Text(
                    section.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ],
              if (errors[section.id] != null) ...[
                const SizedBox(height: 6),
                Text(
                  errors[section.id]!,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildItem(context, index, item);
        }),
        if (items.length < section.maxItems)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => onAddItem(section.id, null),
              icon: const Icon(Icons.add_outlined, size: 18),
              label: Text(section.addButtonLabel),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.trustBlue,
                side: BorderSide(color: AppColors.trustBlue.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildItem(
      BuildContext context, int index, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${section.itemTitlePrefix} ${index + 1}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryNavy,
                      ),
                ),
              ),
              if (items.length > section.minItems)
                TextButton.icon(
                  onPressed: () => onRemoveItem(section.id, index),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: Text(section.removeButtonLabel),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          SectionRenderer(
            section: FormSectionDefinition(
              id: section.id,
              title: '',
              fields: section.fields,
            ),
            formValues: const {},
            errors: errors,
            onFieldChanged: (fieldId, value) =>
                onItemChanged(section.id, index, fieldId, value),
            onRepeatableItemChanged: onItemChanged,
            repeatableItemValues: item,
            repeatableItemIndex: index,
          ),
        ],
      ),
    );
  }
}
