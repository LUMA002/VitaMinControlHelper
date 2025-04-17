import 'package:uuid/uuid.dart';

class IntakeLog {
  final String id;
  final String userSupplementId;
  final DateTime intakeTime;
  final double? dosage;
  final String? unit;
  final DateTime createdAt;

  IntakeLog({
    String? id,
    required this.userSupplementId,
    required this.intakeTime,
    this.dosage,
    this.unit,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  factory IntakeLog.fromJson(Map<String, dynamic> json) {
    return IntakeLog(
      id: json['intakeLogID'] ?? json['id'],
      userSupplementId: json['userSupplementID'] ?? json['userSupplementId'],
      intakeTime: DateTime.parse(json['intakeTime']),
      dosage: json['dosage']?.toDouble(),
      unit: json['unit'],
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'intakeLogID': id,
      'userSupplementID': userSupplementId,
      'intakeTime': intakeTime.toIso8601String(),
      'dosage': dosage,
      'unit': unit,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  IntakeLog copyWith({
    String? userSupplementId,
    DateTime? intakeTime,
    double? dosage,
    String? unit,
  }) {
    return IntakeLog(
      id: id,
      userSupplementId: userSupplementId ?? this.userSupplementId,
      intakeTime: intakeTime ?? this.intakeTime,
      dosage: dosage ?? this.dosage,
      unit: unit ?? this.unit,
      createdAt: createdAt,
    );
  }
}
