import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../core/config/theme_config.dart';

/// Entry point for reviewing a legal document or contract.
///
/// File analysis is intentionally kept on-device until the review service is
/// selected, so this screen remains a distinct, safe destination on mobile.
class DocumentReviewScreen extends StatefulWidget {
  const DocumentReviewScreen({super.key});

  @override
  State<DocumentReviewScreen> createState() => _DocumentReviewScreenState();
}

class _DocumentReviewScreenState extends State<DocumentReviewScreen> {
  PlatformFile? _selectedFile;

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx', 'txt'],
      withData: false,
    );
    if (!mounted || result == null || result.files.isEmpty) return;
    setState(() => _selectedFile = result.files.single);
  }

  @override
  Widget build(BuildContext context) {
    final file = _selectedFile;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Document Review')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Review a document or contract',
                style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Choose a PDF, Word document, or text file to prepare it for review.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _pickDocument,
              icon: const Icon(Icons.upload_file_outlined),
              label: Text(file == null ? 'Choose Document' : 'Change Document'),
            ),
            if (file != null) ...[
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.description_outlined,
                      color: AppColors.primary),
                  title: Text(file.name),
                  subtitle: Text('${(file.size / 1024).ceil()} KB selected'),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Review findings are informational and should be checked by a qualified advocate before signing or filing a document.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
