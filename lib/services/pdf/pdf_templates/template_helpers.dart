import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../legal_pdf_models.dart';

const _margin = 56.0;

pw.MultiPage page(List<pw.Widget> children) => pw.MultiPage(
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

pw.Widget heading(String value, {double size = 12, bool underline = false}) =>
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

pw.Widget line() => pw.Divider(thickness: .7);

List<pw.Widget> personBlock(PersonInfo person) {
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

List<pw.Widget> recipientBlock(RecipientInfo recipient) => [
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

pw.Widget paragraph(String text) => pw.Padding(
    padding: pw.EdgeInsets.only(bottom: 10),
    child: pw.Text(text,
        textAlign: pw.TextAlign.justify,
        style: pw.TextStyle(
            fontSize: 10, lineSpacing: 4, color: PdfColors.black)));
String valueOrBlank(String? value) =>
    value == null || value.trim().isEmpty ? '_______________' : value.trim();

List<String> valuesOrBlank(List<String> values) =>
    values.where((value) => value.trim().isNotEmpty).toList().isEmpty
        ? const ['_______________']
        : values.where((value) => value.trim().isNotEmpty).toList();

pw.Widget lettered(List<String> values) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: valuesOrBlank(values).asMap().entries.map((entry) {
      final label = String.fromCharCode(97 + entry.key);
      return pw.Padding(
          padding: pw.EdgeInsets.only(bottom: 5),
          child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('($label)  ',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
                pw.Expanded(
                    child: pw.Text(entry.value,
                        textAlign: pw.TextAlign.justify,
                        style: pw.TextStyle(
                            fontSize: 10,
                            lineSpacing: 3,
                            color: PdfColors.black)))
              ]));
    }).toList());
pw.Widget numbered(List<String> values) => pw.Column(
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
