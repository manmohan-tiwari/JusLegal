// -----------------------------------------------------------------------------
// pdf_builder.dart — Single parameterized PDF generator for all legal document
// templates (merges pdf_templates/: affidavit, court, letter, notice, rti).
// -----------------------------------------------------------------------------
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'legal_pdf_models.dart';

/// Discriminates which layout [PdfBuilder] renders for a [LegalDocument].
enum DocumentTemplateType { courtComplaint, letter, rti, notice, affidavit }

/// Maps a [LegalDocument] to its template type.
DocumentTemplateType templateTypeOf(LegalDocument doc) {
  switch (doc.documentType) {
    case 'court_complaint':
      return DocumentTemplateType.courtComplaint;
    case 'letter':
      return DocumentTemplateType.letter;
    case 'rti':
      return DocumentTemplateType.rti;
    case 'notice':
      return DocumentTemplateType.notice;
    case 'affidavit':
      return DocumentTemplateType.affidavit;
  }
  throw ArgumentError.value(
      doc.documentType, 'documentType', 'Unsupported legal document type');
}

// ============================ Shared layout helpers ==========================

const _margin = 56.0;

pw.MultiPage _page(List<pw.Widget> children) => pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(_margin),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.center,
        child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}  |  JusLegal — Not a substitute for legal advice',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.black)),
      ),
      build: (_) => children,
    );

pw.Widget _heading(String value, {double size = 12, bool underline = false}) =>
    pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(value,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
              fontSize: size,
              color: PdfColors.black,
              fontWeight: pw.FontWeight.bold,
              decoration: underline ? pw.TextDecoration.underline : null)),
    );

pw.Widget _line() => pw.Divider(thickness: .7);

List<pw.Widget> _personBlock(PersonInfo person) {
  final values = <String>[
    person.fullName,
    if (person.parentOrSpouseName.isNotEmpty) person.parentOrSpouseName,
    if (person.age.isNotEmpty) 'Age: ${person.age}',
    if (person.address.isNotEmpty) person.address,
    if (person.mobile.isNotEmpty) 'Mobile: ${person.mobile}',
    if (person.email.isNotEmpty) 'Email: ${person.email}'
  ];
  return values
      .map((v) => pw.Text(v,
          style: pw.TextStyle(
              fontSize: 10, lineSpacing: 2, color: PdfColors.black)))
      .toList();
}

List<pw.Widget> _recipientBlock(RecipientInfo recipient) => [
      pw.Text(recipient.name,
          style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
              color: PdfColors.black)),
      if (recipient.designation.isNotEmpty)
        pw.Text(recipient.designation,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
      if (recipient.organization.isNotEmpty)
        pw.Text(recipient.organization,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
      if (recipient.address.isNotEmpty)
        pw.Text(recipient.address,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
    ];

pw.Widget _paragraph(String text) => pw.Padding(
    padding: pw.EdgeInsets.only(bottom: 10),
    child: pw.Text(text,
        textAlign: pw.TextAlign.justify,
        style: pw.TextStyle(
            fontSize: 10, lineSpacing: 4, color: PdfColors.black)));

String _valueOrBlank(String? value) =>
    value == null || value.trim().isEmpty ? '_______________' : value.trim();

List<String> _valuesOrBlank(List<String> values) =>
    values.where((value) => value.trim().isNotEmpty).toList().isEmpty
        ? const ['_______________']
        : values.where((value) => value.trim().isNotEmpty).toList();

pw.Widget _lettered(List<String> values) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: _valuesOrBlank(values).asMap().entries.map((entry) {
      final label = String.fromCharCode(97 + entry.key);
      return pw.Padding(
          padding: pw.EdgeInsets.only(bottom: 5),
          child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('($label)  ',
                    style:
                        pw.TextStyle(fontSize: 10, color: PdfColors.black)),
                pw.Expanded(
                    child: pw.Text(entry.value,
                        textAlign: pw.TextAlign.justify,
                        style: pw.TextStyle(
                            fontSize: 10,
                            lineSpacing: 3,
                            color: PdfColors.black)))
              ]));
    }).toList());

pw.Widget _numbered(List<String> values) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: values
        .asMap()
        .entries
        .map((e) => pw.Padding(
            padding: pw.EdgeInsets.only(bottom: 5),
            child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('${e.key + 1}.  ',
                      style:
                          pw.TextStyle(fontSize: 10, color: PdfColors.black)),
                  pw.Expanded(
                      child: pw.Text(e.value,
                          textAlign: pw.TextAlign.justify,
                          style: pw.TextStyle(
                              fontSize: 10,
                              lineSpacing: 3,
                              color: PdfColors.black)))
                ])))
        .toList());

pw.Widget _section(String text) => pw.Padding(
    padding: pw.EdgeInsets.only(top: 8, bottom: 5),
    child: pw.Text(text,
        style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black)));

// ================================= PdfBuilder ================================

/// The single parameterized PDF builder. Replaces the former per-template
/// classes (CourtTemplate, LetterTemplate, RtiTemplate, NoticeTemplate,
/// AffidavitTemplate).
class PdfBuilder {
  const PdfBuilder._();

  /// Builds the PDF bytes for [doc], dispatching on [templateTypeOf].
  static Future<Uint8List> build(pw.Document pdf, LegalDocument doc) async {
    switch (templateTypeOf(doc)) {
      case DocumentTemplateType.courtComplaint:
        return _buildCourt(pdf, doc as CourtComplaintDocument);
      case DocumentTemplateType.letter:
        return _buildLetter(pdf, doc as FormalLetterDocument);
      case DocumentTemplateType.rti:
        return _buildRti(pdf, doc as RtiDocument);
      case DocumentTemplateType.notice:
        return _buildNotice(pdf, doc as LegalNoticeDocument);
      case DocumentTemplateType.affidavit:
        return _buildAffidavit(pdf, doc as AffidavitDocument);
    }
  }

  // ------------------------------- Court -----------------------------------

  static Future<Uint8List> _buildCourt(
      pw.Document pdf, CourtComplaintDocument doc) async {
    pdf.addPage(_page([
      _heading('BEFORE THE DISTRICT CONSUMER DISPUTES REDRESSAL COMMISSION',
          size: 11),
      _heading(_valueOrBlank(doc.district), size: 11),
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
      ..._personBlock(doc.complainant),
      pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('...Complainant(s)',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.black))),
      pw.SizedBox(height: 12),
      _heading('Versus', size: 10),
      pw.Text(_valueOrBlank(doc.oppositeParty.name),
          style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
              color: PdfColors.black)),
      pw.Text(_valueOrBlank(doc.oppositeParty.address),
          style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
      pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('...Opposite Party(ies)',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.black))),
      pw.SizedBox(height: 14),
      _heading('COMPLAINT UNDER SECTION 35 OF THE\nCONSUMER PROTECTION ACT, 2019',
          size: 11),
      _section('1. COMPLAINANT DETAILS'),
      _paragraph(
          'Name: ${_valueOrBlank(doc.complainant.fullName)}\nAge: ${_valueOrBlank(doc.complainant.age)}\nAddress: ${_valueOrBlank(doc.complainant.address)}\nOccupation: _______________'),
      _section('2. OPPOSITE PARTY DETAILS'),
      _paragraph(
          'Name: ${_valueOrBlank(doc.oppositeParty.name)}\nAddress: ${_valueOrBlank(doc.oppositeParty.address)}\nNature of business: ${_valueOrBlank(doc.oppositeParty.designation)}'),
      _section('3. CONSUMER STATUS'),
      _paragraph(
          'The complainant is a consumer as defined under Section 2(7) of the Consumer Protection Act, 2019 because ${_valueOrBlank(doc.consumerStatusReason)}.'),
      _section('4. JURISDICTION'),
      _paragraph(
          'This Commission has jurisdiction to entertain this complaint as follows:\nTerritorial: ${_valueOrBlank(doc.territorialJurisdiction)}\nPecuniary: Value of goods/services = ₹${_valueOrBlank(doc.pecuniaryAmount)}'),
      _section('5. FACTS OF THE CASE'),
      _numbered(_valuesOrBlank(doc.factsOfCase)
          .map((fact) => fact.startsWith('That ') ? fact : 'That $fact')
          .toList()),
      _section('6. CAUSE OF ACTION'),
      _paragraph(
          'The cause of action arose on ${_valueOrBlank(doc.causeOfActionDate)} when ${_valueOrBlank(doc.causeOfActionReason)}.'),
      _section('7. RELIEF SOUGHT / PRAYER'),
      _paragraph(
          'It is, therefore, most respectfully prayed that this Hon\'ble Commission may graciously be pleased to:'),
      _lettered(doc.reliefSought),
      _section('8. DECLARATION'),
      _paragraph(
          'I/We, the complainant(s), do hereby declare that the facts stated above are true and correct to the best of my/our knowledge and belief.'),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('Place: _____________\nDate: ______________',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
        pw.Text(
            '[Complainant Signature]\nName: ${_valueOrBlank(doc.complainant.fullName)}',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
      ]),
    ]));
    return pdf.save();
  }

  // ------------------------------- Letter ----------------------------------

  static Future<Uint8List> _buildLetter(
      pw.Document pdf, FormalLetterDocument doc) async {
    pdf.addPage(_page([
      ..._personBlock(doc.sender),
      pw.SizedBox(height: 10),
      pw.Text('Date: ${doc.dateString}',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
      pw.SizedBox(height: 16),
      ..._recipientBlock(doc.recipient),
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
      ...doc.bodyParagraphs.map(_paragraph),
      _paragraph(doc.closingLine),
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
        _numbered(doc.enclosures)
      ]
    ]));
    return pdf.save();
  }

  // -------------------------------- RTI ------------------------------------

  static Future<Uint8List> _buildRti(
      pw.Document pdf, RtiDocument doc) async {
    pdf.addPage(_page([
      pw.Text('To,', style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
      pw.Text('The Public Information Officer',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
      pw.Text(
          _valueOrBlank(doc.publicAuthority.organization.isEmpty
              ? doc.publicAuthority.name
              : doc.publicAuthority.organization),
          style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
      pw.Text(_valueOrBlank(doc.publicAuthority.address),
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
      _paragraph(
          'I, ${_valueOrBlank(doc.applicant.fullName)}, son/daughter/wife of ${_valueOrBlank(doc.applicant.parentOrSpouseName)}, resident of ${_valueOrBlank(doc.applicant.address)}, do hereby request the following information under the RTI Act, 2005:'),
      _numbered(_valuesOrBlank(doc.informationSought)),
      pw.SizedBox(height: 8),
      _paragraph(
          'The information is required for the period: ${_valueOrBlank(doc.timePeriod)}\nPreferred mode of receiving information: ${_valueOrBlank(doc.preferredFormat)}'),
      _paragraph(
          'I am enclosing an application fee of ₹10/- by way of ${_valueOrBlank(doc.feePaid)} as required under the Act.'),
      _paragraph('I declare that I am a citizen of India.'),
      pw.SizedBox(height: 22),
      pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
              'Yours faithfully,\n\n[Signature]\nName: ${_valueOrBlank(doc.applicant.fullName)}\nAddress: ${_valueOrBlank(doc.applicant.address)}\nPhone: ${_valueOrBlank(doc.applicant.mobile)}\nDate: ${doc.dateString}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.black))),
      pw.SizedBox(height: 15),
      pw.Text(
          'Enclosures:\n1. Application fee ₹10/- via ${_valueOrBlank(doc.feePaid)}\n2. _______________',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
    ]));
    return pdf.save();
  }

  // ------------------------------- Notice ----------------------------------

  static Future<Uint8List> _buildNotice(
      pw.Document pdf, LegalNoticeDocument doc) async {
    final year = doc.date.year;
    final noticeNo =
        'JL/$year/${(doc.date.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}';
    pdf.addPage(_page([
      _heading('LEGAL NOTICE', size: 14),
      pw.Text('Date: ${doc.dateString}',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
      pw.SizedBox(height: 14),
      pw.Text('To,', style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
      ..._recipientBlock(doc.recipient),
      pw.SizedBox(height: 12),
      pw.Text('NOTICE NO.: $noticeNo',
          style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black)),
      pw.SizedBox(height: 12),
      _paragraph(
          'Under instructions from and on behalf of my/our client ${_valueOrBlank(doc.sender.fullName)}, resident of ${_valueOrBlank(doc.sender.address)}, I/We do hereby serve upon you the following notice:'),
      _numbered(_valuesOrBlank(doc.backgroundFacts)
          .map((fact) => fact.startsWith('That ') ? fact : 'That $fact')
          .toList()),
      _paragraph(
          'That your acts constitute ${_valueOrBlank(doc.legalViolation)}.'),
      _paragraph('You are, therefore, called upon to:'),
      _lettered(doc.reliefDemanded),
      _paragraph(
          'TAKE NOTICE that if you fail to comply with the above within ${doc.responseDeadlineDays} days from receipt of this notice, my client shall be constrained to initiate appropriate legal proceedings against you before the competent court/forum, entirely at your risk, cost and consequences.'),
      _paragraph(
          'Issued without prejudice to all other rights and remedies available to my client.'),
      pw.SizedBox(height: 24),
      pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
              '${_valueOrBlank(doc.sender.fullName)}\n${_valueOrBlank(doc.sender.address)}',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 10, color: PdfColors.black))),
      pw.SizedBox(height: 16),
      pw.Text('Sent via: Speed Post / Email / WhatsApp',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
    ]));
    return pdf.save();
  }

  // ------------------------------ Affidavit --------------------------------

  static Future<Uint8List> _buildAffidavit(
      pw.Document pdf, AffidavitDocument doc) async {
    pdf.addPage(_page([
      _heading('AFFIDAVIT', size: 14),
      _paragraph(
          'I, ${_valueOrBlank(doc.deponent.fullName)}, Son/Daughter/Wife of ${_valueOrBlank(doc.deponent.parentOrSpouseName)}, aged about ${_valueOrBlank(doc.deponent.age)} years, resident of ${_valueOrBlank(doc.deponent.address)}, do hereby solemnly affirm and declare on oath as under:'),
      _numbered([
        'That I am the deponent herein and am competent to swear this affidavit.',
        ..._valuesOrBlank(doc.statements)
      ]),
      pw.SizedBox(height: 14),
      pw.Text('VERIFICATION',
          style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
              color: PdfColors.black)),
      _paragraph(
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
