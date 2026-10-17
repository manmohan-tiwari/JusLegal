import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juslegal/core/core.dart';
import '../models/document_definition.dart';
import '../models/document_form_data.dart';
import '../models/form_section_definition.dart';
import 'section_renderer.dart';
import 'repeatable_section.dart';
import 'conditional_section.dart';
import 'form_validator.dart';

typedef OnFieldChanged = void Function(String fieldId, dynamic value);
typedef OnStepChanged = void Function(int step);

class DocumentFormRenderer extends ConsumerStatefulWidget {
  final DocumentDefinition definition;
  final DocumentFormData formData;
  final Map<String, String> errors;
  final int currentStep;
  final OnFieldChanged onFieldChanged;
  final VoidCallback onAddRepeatableItem;
  final void Function(String sectionId, int index) onRemoveRepeatableItem;
  final OnStepChanged onStepChanged;
  final VoidCallback onGenerate;
  final bool isGenerating;
  final String tone;
  final String languageCode;
  final ValueChanged<String> onToneChanged;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<Map<String, String>> onValidationFailed;

  const DocumentFormRenderer({
    super.key,
    required this.definition,
    required this.formData,
    required this.errors,
    required this.currentStep,
    required this.onFieldChanged,
    required this.onAddRepeatableItem,
    required this.onRemoveRepeatableItem,
    required this.onStepChanged,
    required this.onGenerate,
    required this.isGenerating,
    required this.tone,
    required this.languageCode,
    required this.onToneChanged,
    required this.onLanguageChanged,
    required this.onValidationFailed,
  });

  int get totalSteps => definition.sections.length;

  bool get isLastStep => currentStep >= totalSteps - 1;

  bool get isFirstStep => currentStep == 0;

  @override
  ConsumerState<DocumentFormRenderer> createState() =>
      _DocumentFormRendererState();
}

class _DocumentFormRendererState extends ConsumerState<DocumentFormRenderer> {
  final _formKey = GlobalKey<FormState>();

  void _handleNext() {
    final currentSection = widget.definition.sections[widget.currentStep];
    final validator = const FormValidator();
    final sectionErrors = <String, String>{};

    if (currentSection is RepeatableSectionDefinition) {
      sectionErrors.addAll(validator.validateRepeatableSection(
          currentSection, widget.formData.values));
    } else {
      sectionErrors.addAll(
          validator.validateSection(currentSection, widget.formData.values));
    }

    if (sectionErrors.isNotEmpty) {
      widget.onValidationFailed(sectionErrors);
      return;
    }

    if (widget.isLastStep) {
      widget.onGenerate();
    } else {
      widget.onStepChanged(widget.currentStep + 1);
    }
  }

  void _handleBack() {
    if (!widget.isFirstStep) {
      widget.onStepChanged(widget.currentStep - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final section = widget.definition.sections[widget.currentStep];

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(context),
          const SizedBox(height: 20),
          _buildToneSelector(context),
          const SizedBox(height: 20),
          _buildPromptHintCard(context),
          const SizedBox(height: 20),
          _buildSectionContent(section),
          const SizedBox(height: 24),
          _buildStepIndicator(context),
          const SizedBox(height: 12),
          _buildNavigationButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.mustardGold.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.mustardGold.withValues(alpha: 0.4),
              ),
            ),
            child: Icon(
              widget.definition.category.icon,
              color: AppColors.mustardGold,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.definition.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.definition.description,
                  style: const TextStyle(
                    color: AppColors.paleBlue,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToneSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TONE OF DRAFT',
          style: TextStyle(
            color: AppColors.slateBlue,
            fontWeight: FontWeight.w800,
            fontSize: 11,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: ['Formal', 'Assertive', 'Concise'].map((tone) {
            final selected = widget.tone == tone;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => widget.onToneChanged(tone),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.deepNavy : Colors.white,
                      border: Border.all(
                        color:
                            selected ? AppColors.deepNavy : AppColors.outline,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        tone,
                        style: TextStyle(
                          color:
                              selected ? Colors.white : AppColors.deepNavy,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPromptHintCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.paleBlue,
        border: Border.all(
          color: const Color(0xFFD4E2EC),
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: AppColors.slateBlue,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.definition.promptHint,
              style: const TextStyle(
                color: AppColors.deepNavy,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContent(FormSectionDefinition section) {
    if (section is RepeatableSectionDefinition &&
        !section.isVisible(widget.formData.values)) {
      return const SizedBox.shrink();
    }
    if (section.id == 'review') {
      return _buildReview();
    }
    if (section is RepeatableSectionDefinition) {
      final items = widget.formData.getRepeatable(section.id);
      final displayItems = items.isEmpty && section.minItems > 0
          ? List.generate(section.minItems, (_) => <String, dynamic>{})
          : items;
      return RepeatableSectionRenderer(
        section: section,
        items: displayItems,
        errors: widget.errors,
        onItemChanged: (secId, index, fieldId, value) {
          final current = widget.formData.getRepeatable(secId);
          final list = List<Map<String, dynamic>>.from(current);
          while (list.length <= index) {
            list.add({});
          }
          list[index] = Map<String, dynamic>.from(list[index]);
          list[index][fieldId] = value;
          widget.onFieldChanged(secId, list);
        },
        onAddItem: (secId, _) => widget.onAddRepeatableItem(),
        onRemoveItem: (secId, index) {
          if (index != null) {
            widget.onRemoveRepeatableItem(secId, index);
          }
        },
      );
    }

    if (section is ConditionalSectionDefinition) {
      return ConditionalSectionRenderer(
        section: section,
        formValues: widget.formData.values,
        errors: widget.errors,
        onFieldChanged: widget.onFieldChanged,
        onRepeatableItemChanged: (secId, index, fieldId, value) {
          widget.onFieldChanged(secId, value);
        },
      );
    }

    return SectionRenderer(
      section: section,
      formValues: widget.formData.values,
      errors: widget.errors,
      onFieldChanged: widget.onFieldChanged,
      onRepeatableItemChanged: (secId, index, fieldId, value) {},
    );
  }

  Widget _buildReview() {
    final rows = <Widget>[];
    widget.formData.values.forEach((key, value) {
      if (value == null || value.toString().trim().isEmpty) return;
      if (value is List) {
        for (var i = 0; i < value.length; i++) {
          final item = value[i];
          if (item is Map) {
            rows.add(Text(
                '${key == 'landlords' ? 'Landlord' : 'Tenant'} ${i + 1}',
                style: const TextStyle(fontWeight: FontWeight.w700)));
            item.forEach((itemKey, itemValue) {
              if (itemValue.toString().trim().isNotEmpty) {
                rows.add(Text('${_label(itemKey)}: $itemValue'));
              }
            });
          }
        }
      } else {
        rows.add(Text(
            '${_label(key)}: ${value == true ? 'Yes' : value == false ? 'No' : value}'));
      }
      rows.add(const SizedBox(height: 8));
    });
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12)),
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows),
    );
  }

  String _label(String key) =>
      key.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}');



  Widget _buildStepIndicator(BuildContext context) {
    if (widget.definition.sections.length <= 1) {
      return const SizedBox.shrink();
    }
    return Row(
      children: List.generate(widget.definition.sections.length, (index) {
        final isActive = index == widget.currentStep;
        final isCompleted = index < widget.currentStep;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                right: index < widget.definition.sections.length - 1 ? 6 : 0),
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.mustardGold
                    : isCompleted
                        ? AppColors.deepNavy
                        : AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    final canGenerate = widget.isLastStep && !widget.isGenerating;
    final nextLabel = canGenerate ? 'Generate Document' : 'Next';
    final nextIcon =
        canGenerate ? Icons.auto_awesome_rounded : Icons.arrow_forward;

    return Row(
      children: [
        if (!widget.isFirstStep)
          Expanded(
            flex: 1,
            child: OutlinedButton.icon(
              onPressed: widget.isGenerating ? null : _handleBack,
              icon: const Icon(Icons.arrow_back,
                  size: 18, color: AppColors.deepNavy),
              label: const Text(
                'Back',
                style: TextStyle(
                  color: AppColors.deepNavy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.outline),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        if (!widget.isFirstStep) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: widget.isGenerating ? null : _handleNext,
              icon: Icon(nextIcon, size: 20, color: AppColors.deepNavy),
              label: Text(
                widget.isGenerating
                    ? (canGenerate ? 'Generating...' : 'Please wait')
                    : nextLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppColors.deepNavy,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mustardGold,
                foregroundColor: AppColors.deepNavy,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
