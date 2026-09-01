import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'legal_pdf_models.dart';
import 'pdf_builder.dart';

/// The sole public entry point for A4 legal document generation and sharing.
class LegalPdfService {
  const LegalPdfService._();

  static Future<void> showPrintPreview(LegalDocument doc, String locale) =>
      Printing.layoutPdf(
        onLayout: (_) => generateBytes(doc, locale),
        format: PdfPageFormat.a4,
        name: '${_fileName(doc)}.pdf',
      );

  static Future<void> shareAsPdf(LegalDocument doc, String locale) async =>
      Printing.sharePdf(
        bytes: await generateBytes(doc, locale),
        filename: '${_fileName(doc)}.pdf',
      );

  static Future<Uint8List> generateBytes(LegalDocument doc, String locale) =>
      _buildPdf(doc, locale);

  static Future<Uint8List> _buildPdf(LegalDocument doc, String locale) async {
    final pdf = pw.Document(theme: await _buildTheme(locale));
    return PdfBuilder.build(pdf, doc);
  }

  static Future<pw.ThemeData> _buildTheme(String locale) async {
    final pw.Font base;
    final pw.Font bold;

    if (locale == 'hi') {
      final regularData =
          await rootBundle.load('assets/Fonts/NotoSansDevanagari-Regular.ttf');
      final boldData =
          await rootBundle.load('assets/Fonts/NotoSansDevanagari-Bold.ttf');
      base = pw.Font.ttf(regularData);
      bold = pw.Font.ttf(boldData);
    } else {
      base = pw.Font.helvetica();
      bold = pw.Font.helveticaBold();
    }

    return pw.ThemeData.withFont(
      base: base,
      bold: bold,
    ).copyWith(
      defaultTextStyle: pw.TextStyle(
        color: PdfColors.black,
        fontSize: 10.5,
      ),
    );
  }

  static String _fileName(LegalDocument doc) =>
      'JusLegal_${doc.documentType}_${doc.date.toIso8601String().substring(0, 10)}';
}
