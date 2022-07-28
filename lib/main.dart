import 'package:flutter/material.dart';
import 'package:weather_app/my_application.dart';
import 'common/user_defaults.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserDefaults.getPref();
  runApp(const MyApplication());
}
