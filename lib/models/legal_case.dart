class LegalCase {
  final String id;
  final String title;
  final String description;
  final String category;
  final String againstParty;
  final double amount;
  final DateTime date;
  final List<String> documents;
  final CaseStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? location;
  final List<String> evidence;
  final Map<String, dynamic> additionalDetails;

  LegalCase({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.againstParty = '',
    this.amount = 0.0,
    required this.date,
    this.documents = const [],
    this.status = CaseStatus.draft,
    required this.createdAt,
    this.updatedAt,
    this.location,
    this.evidence = const [],
    this.additionalDetails = const {},
  });

  LegalCase copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? againstParty,
    double? amount,
    DateTime? date,
    List<String>? documents,
    CaseStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? location,
    List<String>? evidence,
    Map<String, dynamic>? additionalDetails,
  }) {
    return LegalCase(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      againstParty: againstParty ?? this.againstParty,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      documents: documents ?? this.documents,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
      evidence: evidence ?? this.evidence,
      additionalDetails: additionalDetails ?? this.additionalDetails,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'againstParty': againstParty,
      'amount': amount,
      'date': date.toIso8601String(),
      'documents': documents,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'location': location,
      'evidence': evidence,
      'additionalDetails': additionalDetails,
    };
  }

  factory LegalCase.fromJson(Map<String, dynamic> json) {
    return LegalCase(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      againstParty: json['againstParty'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.parse(json['date'] as String),
      documents: (json['documents'] as List<dynamic>?)?.cast<String>() ?? [],
      status: CaseStatus.values.firstWhere(
        (s) => s.toString() == json['status'],
        orElse: () => CaseStatus.draft,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      location: json['location'] as String?,
      evidence: (json['evidence'] as List<dynamic>?)?.cast<String>() ?? [],
      additionalDetails: json['additionalDetails'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  String toString() {
    return 'LegalCase(id: $id, title: $title, category: $category, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LegalCase && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum CaseStatus {
  draft,
  filed,
  inProgress,
  resolved,
  rejected,
  closed,
}

extension CaseStatusExtension on CaseStatus {
  String get displayName {
    switch (this) {
      case CaseStatus.draft:
        return 'Draft';
      case CaseStatus.filed:
        return 'Filed';
      case CaseStatus.inProgress:
        return 'In Progress';
      case CaseStatus.resolved:
        return 'Resolved';
      case CaseStatus.rejected:
        return 'Rejected';
      case CaseStatus.closed:
        return 'Closed';
    }
  }

  String get description {
    switch (this) {
      case CaseStatus.draft:
        return 'Case is being prepared';
      case CaseStatus.filed:
        return 'Case has been filed with authorities';
      case CaseStatus.inProgress:
        return 'Case is under review';
      case CaseStatus.resolved:
        return 'Case has been successfully resolved';
      case CaseStatus.rejected:
        return 'Case was rejected by authorities';
      case CaseStatus.closed:
        return 'Case has been closed';
    }
  }
}
