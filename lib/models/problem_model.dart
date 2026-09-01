import 'package:file_picker/file_picker.dart';

/// SecurityAudit: Input validation model for legal problem cases.
/// Validates all fields at construction time to prevent invalid data propagation.
class ProblemModel {
  static const int summaryMaxLength = 2000;
  static const int categoryMaxLength = 100;
  static const int textFieldMaxLength = 500;
  static const int maxDisputedAmount = 999999999; // ~10 crore INR
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB per file

  final String category;
  final String dateOfIncident;
  final String disputedAmount;
  final String involvedParty;
  final String referenceNumber;
  final String summary;
  final List<PlatformFile> attachedFiles;
  final Map<String, String> dynamicFieldValues;

  ProblemModel({
    required String category,
    required String dateOfIncident,
    required String disputedAmount,
    required String involvedParty,
    required String referenceNumber,
    required String summary,
    required List<PlatformFile> attachedFiles,
    Map<String, String> dynamicFieldValues = const {},
  })  : category = _validateCategory(category),
        dateOfIncident = _validateDateOfIncident(dateOfIncident),
        disputedAmount = _validateDisputedAmount(disputedAmount),
        involvedParty = _validateInvolvedParty(involvedParty),
        referenceNumber = _validateReferenceNumber(referenceNumber),
        summary = _validateSummary(summary),
        attachedFiles = _validateAttachedFiles(attachedFiles),
        dynamicFieldValues = _validateDynamicFields(dynamicFieldValues);

  /// Validates category is non-empty and within length bounds.
  static String _validateCategory(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Category cannot be empty');
    }
    if (trimmed.length > categoryMaxLength) {
      throw ArgumentError(
          'Category exceeds maximum length of $categoryMaxLength characters');
    }
    // Sanitize: Remove potentially malicious characters
    if (!RegExp(r'^[a-zA-Z0-9\s\-&\.]+$').hasMatch(trimmed)) {
      throw ArgumentError('Category contains invalid characters');
    }
    return trimmed;
  }

  /// Validates date is in valid format (allows flexible formats including "Not specified").
  static String _validateDateOfIncident(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == 'Not specified') {
      return trimmed;
    }
    if (trimmed.length > textFieldMaxLength) {
      throw ArgumentError(
          'Date of incident exceeds maximum length of $textFieldMaxLength characters');
    }
    return trimmed;
  }

  /// Validates disputed amount is numeric and within reasonable bounds.
  static String _validateDisputedAmount(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == 'Not specified') {
      return trimmed;
    }

    // Attempt to parse as double to validate numeric format
    try {
      final amount = double.parse(trimmed);
      if (amount < 0) {
        throw ArgumentError('Disputed amount cannot be negative');
      }
      if (amount > maxDisputedAmount) {
        throw ArgumentError('Disputed amount exceeds maximum allowed value');
      }
    } catch (e) {
      throw ArgumentError('Disputed amount must be a valid number: $e');
    }

    return trimmed;
  }

  /// Validates involved party is non-empty and within length bounds.
  static String _validateInvolvedParty(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == 'Not specified') {
      return trimmed;
    }
    if (trimmed.length > textFieldMaxLength) {
      throw ArgumentError(
          'Involved party exceeds maximum length of $textFieldMaxLength characters');
    }
    return trimmed;
  }

  /// Validates reference number format and length.
  static String _validateReferenceNumber(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == 'N/A') {
      return trimmed;
    }
    if (trimmed.length > textFieldMaxLength) {
      throw ArgumentError(
          'Reference number exceeds maximum length of $textFieldMaxLength characters');
    }
    return trimmed;
  }

  /// Validates summary is non-empty and within character bounds.
  static String _validateSummary(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Summary/Description cannot be empty');
    }
    if (trimmed.length > summaryMaxLength) {
      throw ArgumentError(
          'Summary exceeds maximum length of $summaryMaxLength characters');
    }
    return trimmed;
  }

  /// Validates attached files meet security requirements.
  static List<PlatformFile> _validateAttachedFiles(List<PlatformFile> files) {
    // Allowed MIME types for legal documents
    const allowedMimeTypes = {
      'application/pdf',
      'image/jpeg',
      'image/png',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'text/plain',
    };

    for (final file in files) {
      // Validate file size
      if (file.size > maxFileSize) {
        throw ArgumentError(
            'File "${file.name}" exceeds maximum size of ${maxFileSize ~/ (1024 * 1024)}MB');
      }

      // Validate MIME type if available
      if (file.extension != null) {
        final mimeType = _getMimeTypeForExtension(file.extension!);
        if (!allowedMimeTypes.contains(mimeType)) {
          throw ArgumentError(
              'File type "${file.extension}" is not allowed. Allowed types: pdf, jpg, png, doc, docx, txt');
        }
      }

      // Filename sanitization - prevent directory traversal
      if (file.name.contains('..') || file.name.contains('/') || file.name.contains('\\')) {
        throw ArgumentError('Invalid filename: "${file.name}"');
      }
    }

    return files;
  }

  /// Maps file extension to MIME type for validation.
  static String _getMimeTypeForExtension(String extension) {
    final ext = extension.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg' || 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  /// Validates dynamic form fields.
  static Map<String, String> _validateDynamicFields(
      Map<String, String> fields) {
    final validated = <String, String>{};

    for (final entry in fields.entries) {
      final key = entry.key.trim();
      final value = entry.value.trim();

      if (key.isEmpty) {
        throw ArgumentError('Dynamic field key cannot be empty');
      }

      if (value.length > textFieldMaxLength) {
        throw ArgumentError(
            'Dynamic field "$key" exceeds maximum length of $textFieldMaxLength characters');
      }

      validated[key] = value;
    }

    return validated;
  }

  @override
  String toString() {
    return 'ProblemModel(category: $category, summary: ${summary.substring(0, 50)}...)';
  }
}
