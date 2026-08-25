import 'package:intl/intl.dart';

/// Contact details shared by all printable legal documents.
class PersonInfo {
  const PersonInfo({
    required this.fullName,
    this.parentOrSpouseName = '',
    this.age = '',
    this.address = '',
    this.mobile = '',
    this.email = '',
  });

  final String fullName;
  final String parentOrSpouseName;
  final String age;
  final String address;
  final String mobile;
  final String email;
}

class RecipientInfo {
  const RecipientInfo({
    required this.name,
    this.designation = '',
    this.organization = '',
    this.address = '',
  });

  final String name;
  final String designation;
  final String organization;
  final String address;
}

class OppositePartyInfo {
  const OppositePartyInfo({
    required this.name,
    this.designation = '',
    this.address = '',
    this.contact = '',
  });

  final String name;
  final String designation;
  final String address;
  final String contact;
}

abstract class LegalDocument {
  LegalDocument({required this.title, this.subtitle = '', DateTime? date})
      : date = date ?? DateTime.now();

  final String title;
  final String subtitle;
  final DateTime date;
  String get documentType;
  String get dateString => DateFormat('dd/MM/yyyy').format(date);
  PersonInfo get author;
}

class CourtComplaintDocument extends LegalDocument {
  CourtComplaintDocument({
    required super.title,
    super.subtitle = 'Consumer Protection Act, 2019',
    super.date,
    required this.district,
    required this.state,
    this.complaintNo = '',
    required this.complainant,
    required this.oppositeParty,
    this.consumerStatusReason = '',
    this.territorialJurisdiction = '',
    this.pecuniaryAmount = '',
    this.factsOfCase = const [],
    this.causeOfActionDate = '',
    this.causeOfActionReason = '',
    this.reliefSought = const [],
  });
  final String district, state, complaintNo;
  final String consumerStatusReason, territorialJurisdiction, pecuniaryAmount;
  final List<String> factsOfCase;
  final String causeOfActionDate, causeOfActionReason;
  final PersonInfo complainant;
  final OppositePartyInfo oppositeParty;
  final List<String> reliefSought;
  @override
  String get documentType => 'court_complaint';
  @override
  PersonInfo get author => complainant;
}

class FormalLetterDocument extends LegalDocument {
  FormalLetterDocument({
    required super.title,
    super.subtitle,
    super.date,
    required this.sender,
    required this.recipient,
    required this.subject,
    required this.bodyParagraphs,
    this.closingLine = 'Thank you for your prompt attention to this matter.',
    this.enclosures = const [],
    this.referenceNo = '',
  });
  final PersonInfo sender;
  final RecipientInfo recipient;
  final String subject, closingLine, referenceNo;
  final List<String> bodyParagraphs, enclosures;
  @override
  String get documentType => 'letter';
  @override
  PersonInfo get author => sender;
}

class RtiDocument extends LegalDocument {
  RtiDocument(
      {required super.title,
      super.subtitle = 'Right to Information Act, 2005',
      super.date,
      required this.applicant,
      required this.publicAuthority,
      required this.informationSought,
      this.timePeriod = '',
      this.preferredFormat = 'Certified copies',
      this.feePaid = 'cash / Indian Postal Order'});
  final PersonInfo applicant;
  final RecipientInfo publicAuthority;
  final List<String> informationSought;
  final String timePeriod, preferredFormat, feePaid;
  @override
  String get documentType => 'rti';
  @override
  PersonInfo get author => applicant;
}

class LegalNoticeDocument extends LegalDocument {
  LegalNoticeDocument(
      {required super.title,
      super.subtitle = '',
      super.date,
      required this.sender,
      required this.recipient,
      this.backgroundFacts = const [],
      this.legalViolation = '',
      this.reliefDemanded = const [],
      this.responseDeadlineDays = 30,
      this.viaAdvocate = false});
  final PersonInfo sender;
  final RecipientInfo recipient;
  final List<String> backgroundFacts;
  final String legalViolation;
  final List<String> reliefDemanded;
  final int responseDeadlineDays;
  final bool viaAdvocate;
  @override
  String get documentType => 'notice';
  @override
  PersonInfo get author => sender;
}

class AffidavitDocument extends LegalDocument {
  AffidavitDocument(
      {required super.title,
      super.subtitle = '',
      super.date,
      required this.deponent,
      required this.statements,
      required this.purpose});
  final PersonInfo deponent;
  final List<String> statements;
  final String purpose;
  @override
  String get documentType => 'affidavit';
  @override
  PersonInfo get author => deponent;
}
