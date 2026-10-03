import 'package:flutter/material.dart';
import 'package:juslegal/core/core.dart';
import '../models/form_section_definition.dart';
import '../models/form_field_definition.dart';
import 'field_renderer.dart';

typedef OnFieldChanged = void Function(String fieldId, dynamic value);
typedef OnRepeatableItemChanged = void Function(
    String sectionId, int index, String fieldId, dynamic value);

class SectionRenderer extends StatelessWidget {
  final FormSectionDefinition section;
  final Map<String, dynamic> formValues;
  final Map<String, String> errors;
  final OnFieldChanged onFieldChanged;
  final OnRepeatableItemChanged onRepeatableItemChanged;
  final VoidCallback? onAddRepeatable;
  final ValueChanged<int>? onRemoveRepeatable;
  final Map<String, dynamic>? repeatableItemValues;
  final int? repeatableItemIndex;

  const SectionRenderer({
    super.key,
    required this.section,
    required this.formValues,
    required this.errors,
    required this.onFieldChanged,
    required this.onRepeatableItemChanged,
    this.onAddRepeatable,
    this.onRemoveRepeatable,
    this.repeatableItemValues,
    this.repeatableItemIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (section is ConditionalSectionDefinition) {
      final cond = section as ConditionalSectionDefinition;
      if (!cond.isVisible(formValues)) {
        return const SizedBox.shrink();
      }
    }

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
            ],
          ),
        ),
        ...section.fields.map((field) => _buildField(field)),
      ],
    );
  }

  Widget _buildField(FormFieldDefinition field) {
    final effectiveValues = repeatableItemValues ?? formValues;
    if (!field.isVisible(effectiveValues)) {
      return const SizedBox.shrink();
    }
    return FieldRenderer(
      field: field,
      value: effectiveValues[field.id],
      error: repeatableItemIndex != null
          ? errors['${section.id}_${repeatableItemIndex}_${field.id}']
          : errors[field.id],
      onChanged: (value) {
        if (repeatableItemIndex != null) {
          onRepeatableItemChanged(
              section.id, repeatableItemIndex!, field.id, value);
        } else {
          onFieldChanged(field.id, value);
        }
      },
    );
  }
}
