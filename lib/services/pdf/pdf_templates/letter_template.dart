import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../legal_pdf_models.dart';
import 'template_helpers.dart';

class LetterTemplate {
  static Future<Uint8List> build(pw.Document pdf, FormalLetterDocument doc) async {
    pdf.addPage(page([
      ...personBlock(doc.sender),
      pw.SizedBox(height: 10),
      pw.Text('Date: ${doc.dateString}',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
      pw.SizedBox(height: 16),
      ...recipientBlock(doc.recipient),
      pw.SizedBox(height: 16),
      pw.Text('Re: ${doc.subject}',
          style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black)),
      if (doc.referenceNo.isNotEmpty)
        pw.Text('Order/Ref No.: ${doc.referenceNo}',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
      pw.SizedBox(height: 12),
      pw.Text('Dear Sir/Madam:',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
      pw.SizedBox(height: 10),
      ...doc.bodyParagraphs.map(paragraph),
      paragraph(doc.closingLine),
      pw.SizedBox(height: 12),
      pw.Text('Sincerely,',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
      pw.SizedBox(height: 22),
      pw.Text(doc.sender.fullName,
          style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
      if (doc.enclosures.isNotEmpty) ...[
        pw.SizedBox(height: 14),
        pw.Text('Enclosures:',
            style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black)),
        numbered(doc.enclosures)
      ]
    ]));
    return pdf.save();
  }
}
