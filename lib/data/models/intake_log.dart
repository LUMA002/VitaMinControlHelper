import 'dart:developer';

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
    // Витягаємо ID добавки з усіх можливих джерел
    String? supplementId;
    

    // використовується третій і перший формати (це потрібно буде оптимізувати)
    if (json['userSupplementID'] != null) {
      log("Format 1: Using userSupplementID: ${json['userSupplementID']}");
      supplementId = json['userSupplementID']; // Старий формат
    } else if 
    (json['supplement'] != null && json['supplement']['supplementID'] != null) {
      log("Format 2: Using nested supplement.supplementID: ${json['supplement']['supplementID']}");
      supplementId = json['supplement']['supplementID']; // Новий формат з сервера
    } else if (json['userSupplementId'] != null) {
      log("Format 3: Using userSupplementId: ${json['userSupplementId']}");
      supplementId = json['userSupplementId']; // Альтернативне іменування
    } else if (json['supplementID'] != null) {
      log("Format 4: Using direct supplementID: ${json['supplementID']}");
      supplementId = json['supplementID']; // Прямий формат
    } else {
      log("WARNING: No supplement ID found in JSON: ${json.keys.join(', ')}");
    }

    return IntakeLog(
      // Решта коду без змін
      id: json['logID'] ?? json['intakeLogID'] ?? json['id'],
      userSupplementId: supplementId ?? '', // Забезпечуємо непорожнє значення
      intakeTime:
          json['takenAt'] != null
              ? DateTime.parse(json['takenAt'])
              : (json['intakeTime'] != null
                  ? DateTime.parse(json['intakeTime'])
                  : DateTime.now()),
      dosage: json['quantity']?.toDouble() ?? json['dosage']?.toDouble(),
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
