import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/models/curent_weather_response_model.dart';
import 'package:weather_app/models/five_day_weather_forecast_response_model.dart';
import 'package:weather_app/models/one_call_weather_response_model.dart';
import 'dart:convert';

import 'helpers.dart';

class UserDefaults {
  static SharedPreferences? sharedPreferences;

  static Future<SharedPreferences?> getPref() async {
    sharedPreferences ??= await SharedPreferences.getInstance();
    return sharedPreferences;
  }

  static Future<bool> saveCurrent5daysWeather(
      FiveDaysWeatherForecastResponseModel model) async {
    String user = json.encode(model.toJson());
    printWrapped("5 days weather saved....");
    return await sharedPreferences?.setString('5daysWeather', user) ?? false;
  }

  static Future<FiveDaysWeatherForecastResponseModel?>
      getCurrent5daysWeather() async {
    FiveDaysWeatherForecastResponseModel? model;
    String? result = sharedPreferences?.getString('5daysWeather');
    if (result != null) {
      Map<String, dynamic> json = jsonDecode(result);
      model = FiveDaysWeatherForecastResponseModel.fromJson(json);
      printWrapped("5 Days weather returned");
    }
    return model;
  }

  static Future<bool> saveCurrentWeather(
      CurrentWeatherResponseModel model) async {
    String user = json.encode(model.toJson());
    printWrapped("current weather saved....");
    return await sharedPreferences?.setString('currentWeather', user) ?? false;
  }

  static Future<CurrentWeatherResponseModel?> getCurrentWeather() async {
    CurrentWeatherResponseModel? model;
    String? result = sharedPreferences?.getString('currentWeather');
    if (result != null) {
      Map<String, dynamic> json = jsonDecode(result);
      model = CurrentWeatherResponseModel.fromJson(json);
      printWrapped("current weather returned");
    }
    return model;
  }

  static Future<bool> saveWeatherUnit(String value) async {
    return await sharedPreferences?.setString('weatherUnit', value) ?? false;
  }

  static Future<String?> getWeatherUnit() async {
    return sharedPreferences?.getString('weatherUnit');
  }

  ///one call weather api response
  static Future<bool> saveOneCallWeather(
      OneCallWeatherResponseModel model) async {
    String weather = json.encode(model.toJson());
    printWrapped("one call weather saved....");
    return await sharedPreferences?.setString('oneCallWeather', weather) ??
        false;
  }

  static Future<OneCallWeatherResponseModel?> getOneCallWeather() async {
    OneCallWeatherResponseModel? model;
    String? result = sharedPreferences?.getString('oneCallWeather');
    if (result != null) {
      Map<String, dynamic> json = jsonDecode(result);
      model = OneCallWeatherResponseModel.fromJson(json);
      printWrapped("one call weather returned");
    }
    return model;
  }
}
