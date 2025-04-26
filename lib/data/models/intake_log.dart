import 'dart:developer';

import 'package:uuid/uuid.dart';

class IntakeLog {
  final String id;
  final String userSupplementId;
  final DateTime intakeTime;
  final int quantity; // Змінено тип на int
  final double? dosage; // Додано поле для дозування активної речовини
  final String? unit;
  final DateTime createdAt;

  IntakeLog({
    String? id,
    required this.userSupplementId,
    required this.intakeTime,
    required this.quantity, // Встановлено значення за замовчуванням
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
    } else if (json['supplement'] != null &&
        json['supplement']['supplementID'] != null) {
      log(
        "Format 2: Using nested supplement.supplementID: ${json['supplement']['supplementID']}",
      );
      supplementId =
          json['supplement']['supplementID']; // Новий формат з сервера
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
      id: json['logID'] ?? json['intakeLogID'] ?? json['id'],
      userSupplementId: supplementId ?? '', // Забезпечуємо непорожнє значення
      intakeTime:
          json['takenAt'] != null
              ? DateTime.parse(json['takenAt'])
              : (json['intakeTime'] != null
                  ? DateTime.parse(json['intakeTime'])
                  : DateTime.now()),
      quantity:
          json['quantity'] != null
              ? (json['quantity'] is int
                  ? json['quantity']
                  : json['quantity'].toInt())
              : 1, // Обробка для int
      dosage: json['dosage']?.toDouble(), // Обробка нового поля Dosage
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
      'quantity': quantity,
      'dosage': dosage,
      'unit': unit,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  IntakeLog copyWith({
    String? userSupplementId,
    DateTime? intakeTime,
    int? quantity, // Змінено тип на int
    double? dosage, // Додано поле для дозування
    String? unit,
  }) {
    return IntakeLog(
      id: id,
      userSupplementId: userSupplementId ?? this.userSupplementId,
      intakeTime: intakeTime ?? this.intakeTime,
      quantity: quantity ?? this.quantity,
      dosage: dosage ?? this.dosage,
      unit: unit ?? this.unit,
      createdAt: createdAt,
    );
  }
}
