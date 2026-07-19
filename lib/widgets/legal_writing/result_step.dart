import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../models/document_category_model.dart';
import '../../models/document_type_model.dart';
import 'disclaimer_banner.dart';
import 'section_label.dart';

class ResultStep extends StatelessWidget {
  final DocumentCategory selectedCategory;
  final DocumentType selectedType;
  final String selectedTone;

  final bool loading;
  final String? error;

  final TextEditingController resultController;

  final bool isEditing;

  final VoidCallback onToggleEditing;
  final VoidCallback onRegenerate;
  final VoidCallback onNewDocument;

  const ResultStep({
    super.key,
    required this.selectedCategory,
    required this.selectedType,
    required this.selectedTone,
    required this.loading,
    required this.error,
    required this.resultController,
    required this.isEditing,
    required this.onToggleEditing,
    required this.onRegenerate,
    required this.onNewDocument,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryNavy.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    selectedCategory.icon,
                    size: 14,
                    color: AppColors.primaryNavy,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    selectedType.label,
                    style: const TextStyle(
                      color: AppColors.primaryNavy,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.trustBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.trustBlue.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                selectedTone,
                style: const TextStyle(
                  color: AppColors.trustBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        if (loading) ...[
          const SectionLabel('DRAFTING YOUR DOCUMENT...'),

          const SizedBox(height: 24),

          const Center(
            child: CircularProgressIndicator(),
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              'AI is drafting your ${selectedType.label}...',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        ],

        if (error != null && !loading)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              border: Border.all(
                color: Colors.red.shade300,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Generation failed. Please try again.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color: Colors.red.shade700,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: onRegenerate,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),

        if (resultController.text.isNotEmpty && !loading) ...[
          const SectionLabel('GENERATED DOCUMENT'),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(
                color: AppColors.border,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 16,
                        color: AppColors.trustBlue,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          selectedType.label.toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: AppColors.primaryNavy,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: onToggleEditing,
                        icon: Icon(
                          isEditing
                              ? Icons.lock_outline
                              : Icons.edit_outlined,
                          size: 16,
                        ),
                        label: Text(
                          isEditing ? 'Lock' : 'Edit',
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              AppColors.trustBlue,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize:
                              MaterialTapTargetSize
                                  .shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: resultController,
                    readOnly: !isEditing,
                    maxLines: null,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.8,
                      color: Color(0xFF1F2937),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Not satisfied?',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              TextButton(
                onPressed: onRegenerate,
                child: const Text('Regenerate'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: resultController.text,
                      ),
                    );

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Copied to clipboard',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.copy_outlined,
                    size: 18,
                  ),
                  label: const Text('Copy'),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onNewDocument,
                  icon: const Icon(
                    Icons.add_outlined,
                    size: 18,
                  ),
                  label: const Text('New Document'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const DisclaimerBanner(),
        ],
      ],
    );
  }
}