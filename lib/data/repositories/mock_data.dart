import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vita_min_control_helper/data/models/user.dart';
import 'package:vita_min_control_helper/data/models/supplement.dart';
import 'package:vita_min_control_helper/data/models/supplement_type.dart';
import 'package:vita_min_control_helper/data/models/supplement_form.dart';
import 'package:vita_min_control_helper/data/models/intake_log.dart';
import 'package:vita_min_control_helper/data/models/reminder.dart';

class MockData {
  // Sample user
  static final User defaultUser = User(
    id: 'user-1',
    email: 'test@example.com',
    username: 'TestUser',
    dateOfBirth: DateTime(1995, 5, 15),
    gender: 'Male',
    height: 175.0,
    weight: 70.0,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  );

  // Sample supplement types
  static final List<SupplementType> supplementTypes = [
    SupplementType(id: 'type-1', name: 'Вітамін'),
    SupplementType(id: 'type-2', name: 'Мінерал'),
    SupplementType(id: 'type-3', name: 'Амінокислота'),
    SupplementType(id: 'type-4', name: 'Антиоксидант'),
    SupplementType(id: 'type-5', name: 'Пробіотик'),
  ];

  // Sample supplement forms
  static final List<SupplementForm> supplementForms = [
    SupplementForm(id: 'form-1', name: 'Таблетка'),
    SupplementForm(id: 'form-2', name: 'Капсула'),
    SupplementForm(id: 'form-3', name: 'Порошок'),
    SupplementForm(id: 'form-4', name: 'Рідина'),
    SupplementForm(id: 'form-5', name: 'Гель'),
  ];

  // Sample supplements
  static final List<Supplement> supplements = [
    Supplement(
      id: 'supp-1',
      name: 'Вітамін D3',
      description: 'Важливий для здоров\'я кісток та імунної системи.',
      recommendedDosage: '1000-4000 IU щодня',
      deficiencySymptoms: 'Слабкість м\'язів, втома, біль у кістках',
      overdoseSymptoms: 'Нудота, блювота, слабкість, проблеми з нирками',
      types: [supplementTypes[0]],  // Вітамін
      forms: [supplementForms[0], supplementForms[1]],  // Таблетка, Капсула
    ),
    Supplement(
      id: 'supp-2',
      name: 'Магній',
      description: 'Необхідний для нервової системи та м\'язової функції.',
      recommendedDosage: '300-400 мг щодня',
      deficiencySymptoms: 'М\'язові судоми, втома, аритмія',
      overdoseSymptoms: 'Діарея, нудота, біль у животі',
      types: [supplementTypes[1]],  // Мінерал
      forms: [supplementForms[0], supplementForms[2]],  // Таблетка, Порошок
    ),
    Supplement(
      id: 'supp-3',
      name: 'Омега-3',
      description: 'Поліненасичені жирні кислоти, важливі для серцево-судинної системи.',
      recommendedDosage: '1000-2000 мг щодня',
      deficiencySymptoms: 'Суха шкіра, проблеми з концентрацією, депресія',
      overdoseSymptoms: 'Розлади шлунку, підвищений ризик кровотечі',
      types: [supplementTypes[0]],  // Вітамін
      forms: [supplementForms[1], supplementForms[3]],  // Капсула, Рідина
    ),
    Supplement(
      id: 'supp-4',
      name: 'Цинк',
      description: 'Необхідний для імунної системи та загоєння ран.',
      recommendedDosage: '15-30 мг щодня',
      deficiencySymptoms: 'Повільне загоєння ран, втрата смаку, випадіння волосся',
      overdoseSymptoms: 'Нудота, головний біль, зниження функції імунної системи',
      types: [supplementTypes[1]],  // Мінерал
      forms: [supplementForms[0]],  // Таблетка
    ),
    Supplement(
      id: 'supp-5',
      name: 'Вітамін C',
      description: 'Антиоксидант, важливий для імунної системи та колагену.',
      recommendedDosage: '500-1000 мг щодня',
      deficiencySymptoms: 'Втома, слабкість, повільне загоєння ран',
      overdoseSymptoms: 'Розлади шлунку, нудота, діарея',
      types: [supplementTypes[0], supplementTypes[3]],  // Вітамін, Антиоксидант
      forms: [supplementForms[0], supplementForms[2]],  // Таблетка, Порошок
    ),
  ];

  // Sample reminders
  static List<Reminder> getReminders(String userId) {
    final now = DateTime.now();
    return [
      Reminder(
        id: 'reminder-1',
        userId: userId,
        supplementId: 'supp-1',
        formId: 'form-1',
        frequency: ReminderFrequency.daily,
        timeToTake: const TimeOfDay(hour: 8, minute: 0),
        quantity: 1,
        unit: 'таблетка',
        nextReminder: DateTime(now.year, now.month, now.day, 8, 0),
        stockAmount: 30,
      ),
      Reminder(
        id: 'reminder-2',
        userId: userId,
        supplementId: 'supp-2',
        formId: 'form-2',
        frequency: ReminderFrequency.daily,
        timeToTake: const TimeOfDay(hour: 12, minute: 30),
        quantity: 2,
        unit: 'капсули',
        nextReminder: DateTime(now.year, now.month, now.day, 12, 30),
        stockAmount: 60,
      ),
      Reminder(
        id: 'reminder-3',
        userId: userId,
        supplementId: 'supp-3',
        formId: 'form-1',
        frequency: ReminderFrequency.daily,
        timeToTake: const TimeOfDay(hour: 19, minute: 0),
        quantity: 1,
        unit: 'капсула',
        nextReminder: DateTime(now.year, now.month, now.day, 19, 0),
        stockAmount: 45,
      ),
      Reminder(
        id: 'reminder-4',
        userId: userId,
        supplementId: 'supp-4',
        formId: 'form-0',
        frequency: ReminderFrequency.weekly,
        timeToTake: const TimeOfDay(hour: 10, minute: 0),
        quantity: 1,
        unit: 'таблетка',
        nextReminder: DateTime(now.year, now.month, now.day, 10, 0).add(const Duration(days: 2)),
        stockAmount: 12,
      ),
      Reminder(
        id: 'reminder-5',
        userId: userId,
        supplementId: 'supp-5',
        formId: 'form-2',
        frequency: ReminderFrequency.asNeeded,
        quantity: 1,
        unit: 'порція',
        stockAmount: 20,
      ),
    ];
  }

  // Sample intake logs
  static List<IntakeLog> getIntakeLogs(String userId) {
    final now = DateTime.now();
    return [
      IntakeLog(
        id: 'log-1',
        userId: userId,
        supplementId: 'supp-1',
        formId: 'form-1',
        quantity: 1,
        unit: 'таблетка',
        takenAt: now.subtract(const Duration(days: 1, hours: 8)),
      ),
      IntakeLog(
        id: 'log-2',
        userId: userId,
        supplementId: 'supp-1',
        formId: 'form-1',
        quantity: 1,
        unit: 'таблетка',
        takenAt: now.subtract(const Duration(days: 2, hours: 8)),
      ),
      IntakeLog(
        id: 'log-3',
        userId: userId,
        supplementId: 'supp-2',
        formId: 'form-2',
        quantity: 2,
        unit: 'капсули',
        takenAt: now.subtract(const Duration(days: 1, hours: 12)),
      ),
      IntakeLog(
        id: 'log-4',
        userId: userId,
        supplementId: 'supp-3',
        formId: 'form-1',
        quantity: 1,
        unit: 'капсула',
        takenAt: now.subtract(const Duration(days: 1, hours: 19)),
      ),
      IntakeLog(
        id: 'log-5',
        userId: userId,
        supplementId: 'supp-3',
        formId: 'form-1',
        quantity: 1,
        unit: 'капсула',
        takenAt: now.subtract(const Duration(days: 2, hours: 19)),
      ),
      IntakeLog(
        id: 'log-6',
        userId: userId,
        supplementId: 'supp-3',
        formId: 'form-1',
        quantity: 1,
        unit: 'капсула',
        takenAt: now.subtract(const Duration(days: 3, hours: 19)),
      ),
      IntakeLog(
        id: 'log-7',
        userId: userId,
        supplementId: 'supp-4',
        formId: 'form-0',
        quantity: 1,
        unit: 'таблетка',
        takenAt: now.subtract(const Duration(days: 5, hours: 10)),
      ),
      IntakeLog(
        id: 'log-8',
        userId: userId,
        supplementId: 'supp-5',
        formId: 'form-2',
        quantity: 1,
        unit: 'порція',
        takenAt: now.subtract(const Duration(days: 2, hours: 15)),
      ),
    ];
  }

 /*  // Convert to JSON for storage
  static String getUserJson() {
    return jsonEncode(defaultUser.toJson());
  }

  static String getSupplementsJson() {
    return jsonEncode(supplements.map((s) => s.toJson()).toList());
  }

  static String getSupplementTypesJson() {
    return jsonEncode(supplementTypes.map((t) => t.toJson()).toList());
  }

  static String getSupplementFormsJson() {
    return jsonEncode(supplementForms.map((f) => f.toJson()).toList());
  }

  static String getRemindersJson(String userId) {
    return jsonEncode(getReminders(userId).map((r) => r.toJson()).toList());
  }

  static String getIntakeLogsJson(String userId) {
    return jsonEncode(getIntakeLogs(userId).map((i) => i.toJson()).toList());
  } */
}