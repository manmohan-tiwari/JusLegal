class LegalResultModel {
  final String category;
  final String applicableLaw;
  final String lawSummary;
  final String userRights;
  final List<String> steps;
  final List<Map<String, String>> authorities;
  final List<String> documentsRequired;
  final bool physicalVisitRequired;
  final String? physicalVisitInstructions;
  final int confidence; // 0-100
  final bool isVerified;
  final String complaintHint;
  // New structured fields for detailed report
  final String? caseSummary;
  final Map<String, dynamic>? legalPosition; // {standing: '', strength: 'Strong/Moderate/Weak', explanation: ''}
  final int? strength; // 1-10 case strength score
  final String? legalAnalysis;
  final List<Map<String, String>>? relevantLaws; // [{"law": "", "section": "", "explanation": ""}]
  final List<String>? rightsAvailable;
  final Map<String, List<String>>? evidenceChecklist; // {"available": [], "recommended": []}
  final List<String>? recommendedActions;
  final List<Map<String, String>>? authoritiesDetailed; // [{"name":"","purpose":"","why":"","contact":""}]
  final List<String>? riskFactors;
  final String? estimatedOutcome;
  final String? disclaimer;
  
  // Complaint details extracted from user input
  final String? orderNumber;
  final String? productDetails;
  final String? amountPaid;
  final String? paymentMethod;
  final String? companyName;
  final String? incidentDate;
  final String? location;

  LegalResultModel({
    required this.category,
    required this.applicableLaw,
    required this.lawSummary,
    required this.userRights,
    required this.steps,
    required this.authorities,
    required this.documentsRequired,
    required this.physicalVisitRequired,
    this.physicalVisitInstructions,
    required this.confidence,
    required this.isVerified,
    required this.complaintHint,
    this.caseSummary,
    this.legalPosition,
    this.strength,
    this.legalAnalysis,
    this.relevantLaws,
    this.rightsAvailable,
    this.evidenceChecklist,
    this.recommendedActions,
    this.authoritiesDetailed,
    this.riskFactors,
    this.estimatedOutcome,
    this.disclaimer,
    this.orderNumber,
    this.productDetails,
    this.amountPaid,
    this.paymentMethod,
    this.companyName,
    this.incidentDate,
    this.location,
  });

  factory LegalResultModel.fromJson(Map<String, dynamic> json) {
    return LegalResultModel(
      category: _asString(json['category']),
      applicableLaw: _asString(json['applicable_law']),
      lawSummary: _asString(json['law_summary']),
      userRights: _asString(json['user_rights']),
      steps: _asStringList(json['steps']),
      authorities: List<Map<String, String>>.from(
        ((json['authorities'] as List<dynamic>?) ?? const [])
            .map(_normalizeStringMap),
      ),
      documentsRequired: _asStringList(json['documents_required']),
      physicalVisitRequired: _asBool(json['physical_visit_required']),
      physicalVisitInstructions: _nullableString(json['physical_visit_instructions']),
      confidence: _asInt(json['confidence']),
      isVerified: _asBool(json['isVerified']),
      complaintHint: _asString(json['complaint_hint']),
      orderNumber: _nullableString(json['order_number']),
      productDetails: _nullableString(json['product_details']),
      amountPaid: _nullableString(json['amount_paid']),
      paymentMethod: _nullableString(json['payment_method']),
      companyName: _nullableString(json['company_name']),
      incidentDate: _nullableString(json['incident_date']),
      location: _nullableString(json['location']),
      caseSummary: _nullableString(json['case_summary'] ?? json['caseSummary']),
      strength: _nullableInt(json['strength']),
      legalAnalysis: _nullableString(json['legal_analysis'] ?? json['legalAnalysis']),
      legalPosition: (json['legal_position'] ?? json['legalPosition']) as Map<String, dynamic>?,
      relevantLaws: ((json['relevant_laws'] ?? json['relevantLaws']) as List<dynamic>?)
        ?.map(_normalizeStringMap)
        .toList(),
      rightsAvailable: ((json['rights_available'] ?? json['rightsAvailable'] ?? json['rights']) as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList(),
      evidenceChecklist: ((json['evidence_checklist'] ?? json['evidenceChecklist']) as Map<String, dynamic>?)
        ?.map((k, v) => MapEntry(k.toString(), _asStringList(v))),
      recommendedActions: ((json['recommended_actions'] ?? json['recommendedActions'] ?? json['nextSteps']) as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList(),
      authoritiesDetailed: ((json['authorities_detailed'] ?? json['authoritiesDetailed'] ?? json['authorities']) as List<dynamic>?)
        ?.map(_normalizeStringMap)
        .toList(),
      riskFactors: ((json['risk_factors'] ?? json['riskFactors']) as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList(),
      estimatedOutcome: _nullableString(json['estimated_outcome'] ?? json['estimatedOutcome']),
      disclaimer: _nullableString(json['disclaimer']),
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'applicable_law': applicableLaw,
        'law_summary': lawSummary,
        'user_rights': userRights,
        'steps': steps,
        'authorities': authorities,
        'documents_required': documentsRequired,
        'physical_visit_required': physicalVisitRequired,
        'physical_visit_instructions': physicalVisitInstructions,
        'confidence': confidence,
        'isVerified': isVerified,
        'complaint_hint': complaintHint,
      'case_summary': caseSummary,
      'legal_position': legalPosition,
      'strength': strength,
      'legal_analysis': legalAnalysis,
      'relevant_laws': relevantLaws,
      'rights_available': rightsAvailable,
      'evidence_checklist': evidenceChecklist,
      'recommended_actions': recommendedActions,
      'authorities_detailed': authoritiesDetailed,
      'risk_factors': riskFactors,
      'estimated_outcome': estimatedOutcome,
      'disclaimer': disclaimer,
      };
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

String? _nullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase().trim();
    return lower == 'true' || lower == '1' || lower == 'yes';
  }
  return false;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

int? _nullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

List<String> _asStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
  }
  if (value is String) {
    return value.trim().isEmpty ? [] : [value.trim()];
  }
  return [value.toString()];
}

Map<String, String> _normalizeStringMap(dynamic value) {
  if (value is Map) {
    return value.map((key, entry) => MapEntry(key.toString(), entry == null ? '' : entry.toString()));
  }
  return {'value': value?.toString() ?? ''};
}
