import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart' as dio;
import 'package:weather_app/models/five_day_weather_forecast_response_model.dart';
import 'package:weather_app/models/one_call_weather_response_model.dart';
import 'common/app_pop_ups.dart';
import 'common/constants.dart';
import 'common/helpers.dart';
import 'models/curent_weather_response_model.dart';

class NetworkServices {
  static final dioObj = dio.Dio();

  static Future<CurrentWeatherResponseModel?>
      getCurrentWeatherConditionFromLatLng(
          {required LatLng latLng,
          required String selectedTemperatureUnit,
          bool showAlert = false}) async {
    try {
      printWrapped("getting current weather");
/*      dioObj.interceptors.add(dioObj.DioCacheInterceptor(
          options: CacheOption(CachePolicy.forceCache).options));*/
      var response = await dioObj.get(AppConstants.currentWeatherApi,
          options: dio.Options(headers: {"Content-Type": 'application/json'}),
          queryParameters: {
            "lat": latLng.latitude,
            "lon": latLng.longitude,
            "appId": AppConstants.openWeatherApiKey,
            "units": selectedTemperatureUnit == '°C' ? 'metric' : 'imperial'
          });

      if (response.statusCode == 200 && response.data != null) {
        printWrapped("got weather data...");
        printWrapped(response.data.toString());
        return CurrentWeatherResponseModel.fromJson(response.data);
      } else {
        if (showAlert) {
          AppPopUps.showDialogContent(title: 'Failed to get weather condition');
        }
        return null;
      }
    } catch (e) {
      printWrapped(e.toString());
      AppPopUps.showDialogContent(
          title: 'Failed to connect to server.', dialogType: DialogType.ERROR);
    }
    return null;
  }

  static Future<FiveDaysWeatherForecastResponseModel?> get5DaysWeatherForecast(
      {required LatLng latLng,
      required String selectedTemperatureUnit,
      bool showAlert = false}) async {
    try {
      printWrapped("getting 5 days weather");
      var response = await dioObj.get(AppConstants.fiveDaysWeatherApi,
          options: dio.Options(headers: {"Content-Type": 'application/json'}),
          queryParameters: {
            "lat": latLng.latitude,
            "lon": latLng.longitude,
            "appId": AppConstants.openWeatherApiKey,
            "cnt": "40",
            "units": selectedTemperatureUnit == '°C' ? 'metric' : 'imperial'
          });

      if (response.statusCode == 200 && response.data != null) {
        printWrapped("got 5 days weather data...");
        printWrapped(response.data.toString());
        return FiveDaysWeatherForecastResponseModel.fromJson(response.data);
      } else {
        if (showAlert) {
          AppPopUps.showDialogContent(title: 'Failed to get weather condition');
        }
        return null;
      }
    } catch (e) {
      printWrapped(e.toString());
      AppPopUps.showDialogContent(
          title: 'Failed to connect to server.', dialogType: DialogType.ERROR);
    }
    return null;
  }

  static Future<OneCallWeatherResponseModel?> getOneCallWeatherFromLatLng(
      {required LatLng latLng,
      required String selectedTemperatureUnit,
      bool showAlert = false}) async {
    try {
      printWrapped("getting 5 days weather");
      var response = await dioObj.get(AppConstants.oneCallApi,
          options: dio.Options(headers: {"Content-Type": 'application/json'}),
          queryParameters: {
            "lat": latLng.latitude,
            "lon": latLng.longitude,
            "appId": AppConstants.openWeatherApiKey,
            "cnt": "40",
            "units": selectedTemperatureUnit == '°C' ? 'metric' : 'imperial'
          });

      if (response.statusCode == 200 && response.data != null) {
        printWrapped("got one call weather data...");
        printWrapped(response.data.toString());
        return OneCallWeatherResponseModel.fromJson(response.data);
      } else {
        if (showAlert) {
          AppPopUps.showDialogContent(title: 'Failed to get weather condition');
        }
        return null;
      }
    } catch (e) {
      printWrapped(e.toString());
      AppPopUps.showDialogContent(
          title: 'Failed to connect to server.', dialogType: DialogType.ERROR);
    }
    return null;
  }

  static Future<GeoData> getGeoDataFromCurrentLocation(LatLng coord) async {
    return Geocoder2.getDataFromCoordinates(
        latitude: coord.latitude,
        longitude: coord.longitude,
        googleMapApiKey: AppConstants.googleMapApiKey);
  }

  static Future<LatLng> getUserLocation() async {
    if (!(await checkLocationPermission())) {
      await Geolocator.requestPermission();
    }
    var position = await GeolocatorPlatform.instance.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high));

    return LatLng(position.latitude, position.longitude);
  }

  static Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if ((permission.name == LocationPermission.always.name) ||
        (permission.name == LocationPermission.whileInUse.name)) {
      return true;
    }
    return false;
  }
}
