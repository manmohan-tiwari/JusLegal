class SavedCaseModel {
  final String id;
  final String category;
  final String problemSnippet;
  final DateTime date;
  final String status; // Active | Resolved | Pending
  final Map<String, dynamic> resultJson;

  SavedCaseModel({
    required this.id,
    required this.category,
    required this.problemSnippet,
    required this.date,
    required this.status,
    required this.resultJson,
  });
}
