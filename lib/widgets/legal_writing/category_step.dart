import 'package:flutter/material.dart';

import '../../core/config/templates.dart';
import '../../models/document_category_model.dart';
import '../../models/document_type_model.dart';
import 'category_section.dart';
import 'disclaimer_banner.dart';
import 'section_label.dart';

class CategoryStep extends StatelessWidget {
  final Function(DocumentCategory category, DocumentType type) onTypeSelected;

  const CategoryStep({
    super.key,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DisclaimerBanner(),
        const SizedBox(height: 20),

        const SectionLabel('SELECT DOCUMENT TYPE'),

        const SizedBox(height: 4),

        Padding(
          padding: const EdgeInsets.only(left: 11),
          child: Text(
            'Choose the type of document you want to create',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),

        const SizedBox(height: 16),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: documentCategories.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final category = documentCategories[index];

            return CategorySection(
              category: category,
              onTypeSelected: (type) {
                onTypeSelected(category, type);
              },
            );
          },
        ),
      ],
    );
  }
}
