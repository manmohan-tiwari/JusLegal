import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../legal_pdf_models.dart';
import 'template_helpers.dart';

class CourtTemplate {
  static Future<Uint8List> build(
      pw.Document pdf, CourtComplaintDocument doc) async {
    pdf.addPage(page([
      heading('BEFORE THE DISTRICT CONSUMER DISPUTES REDRESSAL COMMISSION',
          size: 11),
      heading(valueOrBlank(doc.district), size: 11),
      pw.SizedBox(height: 12),
      pw.Text(
          'Complaint No. ${doc.complaintNo.trim().isEmpty ? '_______ of 20____' : doc.complaintNo}',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
      pw.SizedBox(height: 18),
      pw.Text('IN THE MATTER OF:',
          style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
              color: PdfColors.black)),
      pw.SizedBox(height: 8),
      ...personBlock(doc.complainant),
      pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('...Complainant(s)',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.black))),
      pw.SizedBox(height: 12),
      heading('Versus', size: 10),
      pw.Text(valueOrBlank(doc.oppositeParty.name),
          style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
              color: PdfColors.black)),
      pw.Text(valueOrBlank(doc.oppositeParty.address),
          style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
      pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('...Opposite Party(ies)',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.black))),
      pw.SizedBox(height: 14),
      heading(
          'COMPLAINT UNDER SECTION 35 OF THE\nCONSUMER PROTECTION ACT, 2019',
          size: 11),
      _section('1. COMPLAINANT DETAILS'),
      paragraph(
          'Name: ${valueOrBlank(doc.complainant.fullName)}\nAge: ${valueOrBlank(doc.complainant.age)}\nAddress: ${valueOrBlank(doc.complainant.address)}\nOccupation: _______________'),
      _section('2. OPPOSITE PARTY DETAILS'),
      paragraph(
          'Name: ${valueOrBlank(doc.oppositeParty.name)}\nAddress: ${valueOrBlank(doc.oppositeParty.address)}\nNature of business: ${valueOrBlank(doc.oppositeParty.designation)}'),
      _section('3. CONSUMER STATUS'),
      paragraph(
          'The complainant is a consumer as defined under Section 2(7) of the Consumer Protection Act, 2019 because ${valueOrBlank(doc.consumerStatusReason)}.'),
      _section('4. JURISDICTION'),
      paragraph(
          'This Commission has jurisdiction to entertain this complaint as follows:\nTerritorial: ${valueOrBlank(doc.territorialJurisdiction)}\nPecuniary: Value of goods/services = ₹${valueOrBlank(doc.pecuniaryAmount)}'),
      _section('5. FACTS OF THE CASE'),
      numbered(valuesOrBlank(doc.factsOfCase)
          .map((fact) => fact.startsWith('That ') ? fact : 'That $fact')
          .toList()),
      _section('6. CAUSE OF ACTION'),
      paragraph(
          'The cause of action arose on ${valueOrBlank(doc.causeOfActionDate)} when ${valueOrBlank(doc.causeOfActionReason)}.'),
      _section('7. RELIEF SOUGHT / PRAYER'),
      paragraph(
          'It is, therefore, most respectfully prayed that this Hon\'ble Commission may graciously be pleased to:'),
      lettered(doc.reliefSought),
      _section('8. DECLARATION'),
      paragraph(
          'I/We, the complainant(s), do hereby declare that the facts stated above are true and correct to the best of my/our knowledge and belief.'),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Place: _____________\nDate: ______________',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
        pw.Text(
            '[Complainant Signature]\nName: ${valueOrBlank(doc.complainant.fullName)}',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
      ]),
    ]));
    return pdf.save();
  }

  static pw.Widget _section(String text) => pw.Padding(
      padding: pw.EdgeInsets.only(top: 8, bottom: 5),
      child: pw.Text(text,
          style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black)));
}
