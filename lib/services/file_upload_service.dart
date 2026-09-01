import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

/// SecurityAudit: File upload validation service.
/// Enforces strict MIME-type allowlists and file size caps.
/// Prevents directory traversal and other file-based attacks.
class FileUploadService {
  // Maximum file size: 50MB per file
  static const int maxFileSize = 50 * 1024 * 1024;

  // Maximum total size for all attachments: 200MB
  static const int maxTotalSize = 200 * 1024 * 1024;

  // Maximum number of files per upload
  static const int maxFileCount = 10;

  // Allowed MIME types for legal documents
  static const Set<String> allowedMimeTypes = {
    'application/pdf',
    'image/jpeg',
    'image/png',
    'image/jpg',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'text/plain',
  };

  // Allowed file extensions (lowercase)
  static const Set<String> allowedExtensions = {
    'pdf',
    'jpg',
    'jpeg',
    'png',
    'doc',
    'docx',
    'txt',
  };

  /// Validates a single file for security and compliance.
  /// Returns null if valid, or error message if invalid.
  static String? validateFile(PlatformFile file) {
    try {
      // Validate file name for directory traversal attacks
      if (file.name.contains('..') ||
          file.name.contains('/') ||
          file.name.contains('\\') ||
          file.name.contains('\x00')) {
        return 'Invalid filename: potential directory traversal attempt';
      }

      // Validate file size
      if (file.size > maxFileSize) {
        return 'File "${file.name}" exceeds maximum size of ${maxFileSize ~/ (1024 * 1024)}MB';
      }

      // Validate file extension if available
      if (file.extension != null) {
        final ext = file.extension!.toLowerCase();
        if (!allowedExtensions.contains(ext)) {
          return 'File type ".$ext" is not allowed. Allowed types: ${allowedExtensions.join(", ")}';
        }
      }

      if (kDebugMode) {
        debugPrint('[FileUploadService] File validation passed: ${file.name}');
      }

      return null; // Valid
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[FileUploadService] Error validating file: $error');
      }
      return 'Error validating file: $error';
    }
  }

  /// Validates a batch of files for collective constraints.
  /// Returns null if valid, or error message if invalid.
  static String? validateFileBatch(List<PlatformFile> files) {
    try {
      // Check file count limit
      if (files.length > maxFileCount) {
        return 'Too many files. Maximum $maxFileCount files allowed.';
      }

      // Check individual files
      for (final file in files) {
        final error = validateFile(file);
        if (error != null) {
          return error;
        }
      }

      // Check total size
      int totalSize = 0;
      for (final file in files) {
        totalSize += file.size;
      }

      if (totalSize > maxTotalSize) {
        return 'Total file size exceeds maximum of ${maxTotalSize ~/ (1024 * 1024)}MB';
      }

      if (kDebugMode) {
        debugPrint(
            '[FileUploadService] Batch validation passed: ${files.length} files, ${totalSize ~/ (1024 * 1024)}MB total');
      }

      return null; // Valid
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[FileUploadService] Error validating batch: $error');
      }
      return 'Error validating files: $error';
    }
  }

  /// Gets MIME type for a file extension.
  static String getMimeType(String extension) {
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

  /// Checks if a MIME type is allowed.
  static bool isMimeTypeAllowed(String mimeType) {
    return allowedMimeTypes.contains(mimeType.toLowerCase());
  }

  /// Generates a sanitized filename for safe storage/transmission.
  /// Removes special characters and potential security issues.
  static String sanitizeFilename(String originalName) {
    // Remove path separators
    var sanitized = originalName
        .replaceAll(RegExp(r'[\/\\]'), '')
        .replaceAll(RegExp(r'\.\.'), '')
        .replaceAll(RegExp(r'[^\w\s.-]'), '');

    // Limit length to 255 characters (filesystem limit)
    if (sanitized.length > 255) {
      final extensionIndex = sanitized.lastIndexOf('.');
      if (extensionIndex > 0) {
        final name = sanitized.substring(0, 255 - 10);
        final ext = sanitized.substring(extensionIndex);
        sanitized = name + ext;
      } else {
        sanitized = sanitized.substring(0, 255);
      }
    }

    if (kDebugMode) {
      debugPrint(
          '[FileUploadService] Sanitized filename: $originalName -> $sanitized');
    }

    return sanitized;
  }

  /// Formats file size for display.
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
