import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../legal_pdf_models.dart';
import 'template_helpers.dart';

class AffidavitTemplate {
  static Future<Uint8List> build(pw.Document pdf, AffidavitDocument doc) async {
    pdf.addPage(page([
      heading('AFFIDAVIT', size: 14),
      paragraph(
          'I, ${valueOrBlank(doc.deponent.fullName)}, Son/Daughter/Wife of ${valueOrBlank(doc.deponent.parentOrSpouseName)}, aged about ${valueOrBlank(doc.deponent.age)} years, resident of ${valueOrBlank(doc.deponent.address)}, do hereby solemnly affirm and declare on oath as under:'),
      numbered([
        'That I am the deponent herein and am competent to swear this affidavit.',
        ...valuesOrBlank(doc.statements)
      ]),
      pw.SizedBox(height: 14),
      pw.Text('VERIFICATION',
          style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
              color: PdfColors.black)),
      paragraph(
          'Verified at _____________ on this ${doc.dateString} that the contents of the above affidavit are true and correct to the best of my knowledge and belief and nothing material has been concealed therefrom.'),
      pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('DEPONENT',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.black))),
      pw.SizedBox(height: 24),
      pw.Text(
          'Solemnly affirmed before me on ${doc.dateString}\n\nNOTARY PUBLIC / OATH COMMISSIONER',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
    ]));
    return pdf.save();
  }
}
