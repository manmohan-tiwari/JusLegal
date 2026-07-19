class Authority {
  final String name;
  final String? contact;
  final String purpose;
  final String action;
  final String? website;

  Authority({
    required this.name,
    this.contact,
    required this.purpose,
    required this.action,
    this.website,
  });

  factory Authority.fromJson(Map<String, dynamic> json) => Authority(
        name: json['name'] as String,
        contact: json['contact'] as String?,
        purpose: json['purpose'] as String,
        action: json['action'] as String,
        website: json['website'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'contact': contact,
        'purpose': purpose,
        'action': action,
        'website': website,
      };
}
