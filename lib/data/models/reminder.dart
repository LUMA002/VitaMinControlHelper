import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

enum ReminderFrequency {
  daily,
  weekly,
  asNeeded,
}

class Reminder {
  final String id;
  final String userId;
  final String supplementId;
  final String? formId;
  final ReminderFrequency frequency;
  final TimeOfDay? timeToTake;
  final double quantity;
  final String unit;
  final DateTime? nextReminder;
  final bool isConfirmed;
  final int stockAmount;

  Reminder({
    String? id,
    required this.userId,
    required this.supplementId,
    this.formId,
    required this.frequency,
    this.timeToTake,
    required this.quantity,
    required this.unit,
    this.nextReminder,
    this.isConfirmed = false,
    this.stockAmount = 0,
  }) : id = id ?? const Uuid().v4();

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      userId: json['userId'],
      supplementId: json['supplementId'],
      formId: json['formId'],
      frequency: ReminderFrequency.values.byName(json['frequency']),
      timeToTake: json['timeToTake'] != null
          ? TimeOfDay(
              hour: int.parse(json['timeToTake'].split(':')[0]),
              minute: int.parse(json['timeToTake'].split(':')[1]),
            )
          : null,
      quantity: json['quantity'],
      unit: json['unit'],
      nextReminder: json['nextReminder'] != null
          ? DateTime.parse(json['nextReminder'])
          : null,
      isConfirmed: json['isConfirmed'] ?? false,
      stockAmount: json['stockAmount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'supplementId': supplementId,
      'formId': formId,
      'frequency': frequency.name,
      'timeToTake': timeToTake != null
          ? '${timeToTake!.hour.toString().padLeft(2, '0')}:${timeToTake!.minute.toString().padLeft(2, '0')}'
          : null,
      'quantity': quantity,
      'unit': unit,
      'nextReminder': nextReminder?.toIso8601String(),
      'isConfirmed': isConfirmed,
      'stockAmount': stockAmount,
    };
  }

  Reminder copyWith({
    String? supplementId,
    String? formId,
    ReminderFrequency? frequency,
    TimeOfDay? timeToTake,
    double? quantity,
    String? unit,
    DateTime? nextReminder,
    bool? isConfirmed,
    int? stockAmount,
  }) {
    return Reminder(
      id: id,
      userId: userId,
      supplementId: supplementId ?? this.supplementId,
      formId: formId ?? this.formId,
      frequency: frequency ?? this.frequency,
      timeToTake: timeToTake ?? this.timeToTake,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      nextReminder: nextReminder ?? this.nextReminder,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      stockAmount: stockAmount ?? this.stockAmount,
    );
  }
}