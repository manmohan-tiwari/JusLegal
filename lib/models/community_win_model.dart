class CommunityWin {
  final String city;
  final String category;
  final String outcome;
  final String law;

  CommunityWin({
    required this.city,
    required this.category,
    required this.outcome,
    required this.law,
  });

  factory CommunityWin.fromJson(Map<String, dynamic> json) => CommunityWin(
        city: json['city'] as String,
        category: json['category'] as String,
        outcome: json['outcome'] as String,
        law: json['law'] as String,
      );

  Map<String, dynamic> toJson() => {
        'city': city,
        'category': category,
        'outcome': outcome,
        'law': law,
      };
}
