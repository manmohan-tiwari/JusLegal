import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/config/theme_config.dart';
import '../../models/form_template_model.dart';
import '../section_label.dart';

class FilledFormResult extends StatefulWidget {
  final String generatedText;
  final FormTemplateModel form;
  final VoidCallback onRegenerate;
  final VoidCallback onNewForm;

  const FilledFormResult({
    super.key,
    required this.generatedText,
    required this.form,
    required this.onRegenerate,
    required this.onNewForm,
  });

  @override
  State<FilledFormResult> createState() => _FilledFormResultState();
}

class _FilledFormResultState extends State<FilledFormResult> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.generatedText);
  }

  @override
  void didUpdateWidget(FilledFormResult oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.generatedText != widget.generatedText) {
      _controller.text = widget.generatedText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: _controller.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Form copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Form header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryNavy, AppColors.trustBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.form.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                widget.form.actReference,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Submit to: ${widget.form.authority}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Documents required
        if (widget.form.documents.isNotEmpty) ...[
          SectionLabel('DOCUMENTS TO ATTACH'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.trustBlue.withValues(alpha: 0.05),
              border:
                  Border.all(color: AppColors.trustBlue.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.form.documents
                  .map((doc) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.attach_file_rounded,
                                size: 14, color: AppColors.trustBlue),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(doc,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: AppColors.primaryNavy,
                                          height: 1.4)),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Instructions
        SectionLabel('SUBMISSION INSTRUCTIONS'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.legalGold.withValues(alpha: 0.08),
            border:
                Border.all(color: AppColors.legalGold.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.directions_outlined,
                  color: AppColors.legalGold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.form.instructions,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryNavy,
                        height: 1.5,
                      ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Generated form document
        SectionLabel('FILLED FORM'),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toolbar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.article_outlined,
                        size: 16, color: AppColors.trustBlue),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.form.title.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.primaryNavy,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => setState(() => _isEditing = !_isEditing),
                      icon: Icon(
                        _isEditing ? Icons.lock_outline : Icons.edit_outlined,
                        size: 16,
                      ),
                      label: Text(_isEditing ? 'Lock' : 'Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.trustBlue,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(14),
                child: TextField(
                  controller: _controller,
                  readOnly: !_isEditing,
                  maxLines: null,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.8,
                    color: Color(0xFF1F2937),
                    fontFamily: 'monospace',
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

        // Regenerate row
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Not satisfied?',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary)),
            TextButton(
              onPressed: widget.onRegenerate,
              child: const Text('Regenerate'),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _copy,
                icon: const Icon(Icons.copy_outlined, size: 18),
                label: const Text('Copy Form'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryNavy,
                  side: BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onNewForm,
                icon: const Icon(Icons.add_outlined, size: 18),
                label: const Text('New Form'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryNavy,
                  side: BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
