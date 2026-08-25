import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../legal_pdf_models.dart';
import 'template_helpers.dart';

class RtiTemplate {
  static Future<Uint8List> build(pw.Document pdf, RtiDocument doc) async {
    pdf.addPage(page([
      pw.Text('To,', style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
      pw.Text('The Public Information Officer',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
      pw.Text(
          valueOrBlank(doc.publicAuthority.organization.isEmpty
              ? doc.publicAuthority.name
              : doc.publicAuthority.organization),
          style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
      pw.Text(valueOrBlank(doc.publicAuthority.address),
          style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
      pw.SizedBox(height: 16),
      pw.Text(
          'Subject: Application under Section 6(1) of the Right to Information Act, 2005',
          style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black)),
      pw.SizedBox(height: 16),
      pw.Text('Sir/Madam,',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
      pw.SizedBox(height: 10),
      paragraph(
          'I, ${valueOrBlank(doc.applicant.fullName)}, son/daughter/wife of ${valueOrBlank(doc.applicant.parentOrSpouseName)}, resident of ${valueOrBlank(doc.applicant.address)}, do hereby request the following information under the RTI Act, 2005:'),
      numbered(valuesOrBlank(doc.informationSought)),
      pw.SizedBox(height: 8),
      paragraph(
          'The information is required for the period: ${valueOrBlank(doc.timePeriod)}\nPreferred mode of receiving information: ${valueOrBlank(doc.preferredFormat)}'),
      paragraph(
          'I am enclosing an application fee of ₹10/- by way of ${valueOrBlank(doc.feePaid)} as required under the Act.'),
      paragraph('I declare that I am a citizen of India.'),
      pw.SizedBox(height: 22),
      pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
              'Yours faithfully,\n\n[Signature]\nName: ${valueOrBlank(doc.applicant.fullName)}\nAddress: ${valueOrBlank(doc.applicant.address)}\nPhone: ${valueOrBlank(doc.applicant.mobile)}\nDate: ${doc.dateString}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.black))),
      pw.SizedBox(height: 15),
      pw.Text(
          'Enclosures:\n1. Application fee ₹10/- via ${valueOrBlank(doc.feePaid)}\n2. _______________',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
    ]));
    return pdf.save();
  }
}
