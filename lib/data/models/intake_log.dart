import 'package:uuid/uuid.dart';

class IntakeLog {
  final String id;
  final String userId;
  final String supplementId;
  final String? formId;
  final double quantity;
  final String unit;
  final double? stockAmount;
  final DateTime takenAt;

  IntakeLog({
    String? id,
    required this.userId,
    required this.supplementId,
    this.formId,
    required this.quantity,
    required this.unit,
    this.stockAmount,
    DateTime? takenAt,
  })  : id = id ?? const Uuid().v4(),
        takenAt = takenAt ?? DateTime.now();

  factory IntakeLog.fromJson(Map<String, dynamic> json) {
    return IntakeLog(
      id: json['id'],
      userId: json['userId'],
      supplementId: json['supplementId'],
      formId: json['formId'],
      quantity: json['quantity'],
      unit: json['unit'],
      stockAmount: json['stockAmount'],
      takenAt: DateTime.parse(json['takenAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'supplementId': supplementId,
      'formId': formId,
      'quantity': quantity,
      'unit': unit,
      'stockAmount': stockAmount,
      'takenAt': takenAt.toIso8601String(),
    };
  }
}