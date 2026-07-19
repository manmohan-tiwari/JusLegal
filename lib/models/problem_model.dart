import 'package:file_picker/file_picker.dart';

class ProblemModel {
  final String category;
  final String dateOfIncident;
  final String disputedAmount;
  final String involvedParty;
  final String referenceNumber;
  final String summary;
  final List<PlatformFile> attachedFiles;
  final Map<String, String> dynamicFieldValues;

  ProblemModel({
    required this.category,
    required this.dateOfIncident,
    required this.disputedAmount,
    required this.involvedParty,
    required this.referenceNumber,
    required this.summary,
    required this.attachedFiles,
    this.dynamicFieldValues = const {},
  });
}
