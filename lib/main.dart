import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_min_control_helper/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vita_min_control_helper/data/repositories/local/local_storage_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        localStorageRepositoryProvider.overrideWith(
          (ref) => LocalStorageRepository(sharedPreferences),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

