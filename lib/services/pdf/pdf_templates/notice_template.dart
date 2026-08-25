import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../legal_pdf_models.dart';
import 'template_helpers.dart';

class NoticeTemplate {
  static Future<Uint8List> build(pw.Document pdf, LegalNoticeDocument doc) async {
    final year = doc.date.year;
    final noticeNo =
        'JL/$year/${(doc.date.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}';
    pdf.addPage(page([
      heading('LEGAL NOTICE', size: 14),
      pw.Text('Date: ${doc.dateString}',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
      pw.SizedBox(height: 14),
      pw.Text('To,', style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
      ...recipientBlock(doc.recipient),
      pw.SizedBox(height: 12),
      pw.Text('NOTICE NO.: $noticeNo',
          style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black)),
      pw.SizedBox(height: 12),
      paragraph(
          'Under instructions from and on behalf of my/our client ${valueOrBlank(doc.sender.fullName)}, resident of ${valueOrBlank(doc.sender.address)}, I/We do hereby serve upon you the following notice:'),
      numbered(valuesOrBlank(doc.backgroundFacts)
          .map((fact) => fact.startsWith('That ') ? fact : 'That $fact')
          .toList()),
      paragraph(
          'That your acts constitute ${valueOrBlank(doc.legalViolation)}.'),
      paragraph('You are, therefore, called upon to:'),
      lettered(doc.reliefDemanded),
      paragraph(
          'TAKE NOTICE that if you fail to comply with the above within ${doc.responseDeadlineDays} days from receipt of this notice, my client shall be constrained to initiate appropriate legal proceedings against you before the competent court/forum, entirely at your risk, cost and consequences.'),
      paragraph(
          'Issued without prejudice to all other rights and remedies available to my client.'),
      pw.SizedBox(height: 24),
      pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
              '${valueOrBlank(doc.sender.fullName)}\n${valueOrBlank(doc.sender.address)}',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 10, color: PdfColors.black))),
      pw.SizedBox(height: 16),
      pw.Text('Sent via: Speed Post / Email / WhatsApp',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
    ]));
    return pdf.save();
  }
}
