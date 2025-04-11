import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_min_control_helper/app/app.dart';
//import 'package:hive_flutter/hive_flutter.dart';

//Future<void> main() async {|
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  //await Hive.initFlutter();
  
  // Register Hive adapters (we'll implement these later)
  // await Hive.openBox('userData');
  // await Hive.openBox('medications');
  // await Hive.openBox('trackingData');
  
  runApp(const ProviderScope(child: MyApp()));
}
