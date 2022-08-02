import 'package:flutter/material.dart';
import 'package:weather_app/common/helpers.dart';
import 'package:weather_app/common/hive_db.dart';
import 'package:weather_app/models/custom_weather_info_model.dart';
import 'package:weather_app/my_application.dart';
import 'common/user_defaults.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserDefaults.getPref();
  await HiveDb.init();
  // await HiveDb.clearDb();

  runApp(const MyApplication());
}
