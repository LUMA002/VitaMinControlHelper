import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

//enum ReminderFrequency { daily, weekly, monthly, asNeeded }
enum ReminderFrequency { daily }

class Reminder {
  final String id;
  final String userId;
  final String supplementId;
  final ReminderFrequency? frequency;
  final TimeOfDay? timeToTake;
  final int quantity;
  final double? dosage; // Додано нове поле для дозування активної речовини
  final String unit;
  final DateTime? nextReminder;
  final bool isConfirmed;
  final int stockAmount;
  final String? measurementUnit;

  Reminder({
    String? id,
    required this.userId,
    required this.supplementId,
    this.frequency,
    this.timeToTake,
    required this.quantity,
    required this.dosage, // Додано параметр dosage
    required this.unit,
    this.nextReminder,
    this.isConfirmed = false,
    this.stockAmount = 0,
    this.measurementUnit,
  }) : id = id ?? const Uuid().v4();

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      userId: json['userId'],
      supplementId: json['supplementId'],
      frequency:
          json['frequency'] != null
              ? ReminderFrequency.values.byName(json['frequency'])
              : null,
      timeToTake:
          json['timeToTake'] != null
              ? TimeOfDay(
                hour: int.parse(json['timeToTake'].split(':')[0]),
                minute: int.parse(json['timeToTake'].split(':')[1]),
              )
              : null,
      quantity: json['quantity'],
      dosage: json['dosage'], // Додано параметр dosage
      unit: json['unit'],
      nextReminder:
          json['nextReminder'] != null
              ? DateTime.parse(json['nextReminder'])
              : null,
      isConfirmed: json['isConfirmed'] ?? false,
      stockAmount: json['stockAmount'] ?? 0,
      measurementUnit: json['measurementUnit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'supplementId': supplementId,
      'frequency': frequency?.name,
      'timeToTake':
          timeToTake != null
              ? '${timeToTake!.hour.toString().padLeft(2, '0')}:${timeToTake!.minute.toString().padLeft(2, '0')}'
              : null,
      'quantity': quantity,
      'dosage': dosage, // Додано параметр dosage
      'unit': unit,
      'nextReminder': nextReminder?.toIso8601String(),
      'isConfirmed': isConfirmed,
      'stockAmount': stockAmount,
      'measurementUnit': measurementUnit,
    };
  }

  Reminder copyWith({
    String? supplementId,
    String? formId,
    ReminderFrequency? frequency,
    TimeOfDay? timeToTake,
    int? quantity,
    double? dosage, // Додано параметр dosage
    String? unit,
    DateTime? nextReminder,
    bool? isConfirmed,
    int? stockAmount,
    double? activeIngredientAmount,
    String? measurementUnit,
  }) {
    return Reminder(
      id: id,
      userId: userId,
      supplementId: supplementId ?? this.supplementId,
      frequency: frequency ?? this.frequency,
      timeToTake: timeToTake ?? this.timeToTake,
      quantity: quantity ?? this.quantity,
      dosage: dosage ?? this.dosage, // Додано параметр dosage
      unit: unit ?? this.unit,
      nextReminder: nextReminder ?? this.nextReminder,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      stockAmount: stockAmount ?? this.stockAmount,
      measurementUnit: measurementUnit ?? this.measurementUnit,
    );
  }
}
