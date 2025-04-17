// DEPRECATED: This file is being phased out in favor of actual API calls.
// Do not use this file for new code! Instead, use the appropriate repository
// with real API integration.

import 'package:flutter/material.dart';
import 'package:vita_min_control_helper/data/models/user.dart';
import 'package:vita_min_control_helper/data/models/supplement.dart';
import 'package:vita_min_control_helper/data/models/supplement_type.dart';
import 'package:vita_min_control_helper/data/models/supplement_form.dart';
import 'package:vita_min_control_helper/data/models/intake_log.dart';
import 'package:vita_min_control_helper/data/models/reminder.dart';

class MockData {
  // This class is deprecated and will be removed in a future version

  // Placeholder data that will be removed
  static final User defaultUser = User(
    id: 'user-1',
    email: 'test@example.com',
    username: 'TestUser',
    isGuest: false,
  );

  static final List<SupplementType> supplementTypes = [];
  static final List<SupplementForm> supplementForms = [];
  static final List<Supplement> supplements = [];

  static List<Reminder> getReminders(String userId) {
    return [];
  }

  static List<IntakeLog> getIntakeLogs(String userId) {
    return [];
  }

  static final List<Supplement> _customSupplements = [];

  static List<Supplement> get allSupplements {
    return [];
  }

  static void addCustomSupplement(Supplement supplement) {
    // Do nothing
  }
}
