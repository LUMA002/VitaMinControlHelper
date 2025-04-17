class UserSupplement {
  final String id;
  final String supplementId;
  final String userId;
  final double? dosage;
  final String? unit;
  final String? instructions;
  final DateTime createdAt;

  UserSupplement({
    required this.id,
    required this.supplementId,
    required this.userId,
    this.dosage,
    this.unit,
    this.instructions,
    required this.createdAt,
  });

  factory UserSupplement.fromJson(Map<String, dynamic> json) {
    return UserSupplement(
      id: json['userSupplementID'],
      supplementId: json['supplementID'] ?? json['supplement']['supplementID'],
      userId: json['userID'],
      dosage: json['defaultDosage'],
      unit: json['defaultUnit'],
      instructions: json['instructions'],
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userSupplementID': id,
      'supplementID': supplementId,
      'userID': userId,
      'defaultDosage': dosage,
      'defaultUnit': unit,
      'instructions': instructions,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserSupplement copyWith({
    String? id,
    String? supplementId,
    String? userId,
    double? dosage,
    String? unit,
    String? instructions,
    DateTime? createdAt,
  }) {
    return UserSupplement(
      id: id ?? this.id,
      supplementId: supplementId ?? this.supplementId,
      userId: userId ?? this.userId,
      dosage: dosage ?? this.dosage,
      unit: unit ?? this.unit,
      instructions: instructions ?? this.instructions,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
