import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:weather_app/common/user_defaults.dart';
import 'package:weather_app/models/curent_weather_response_model.dart';
import 'package:weather_app/models/five_day_weather_forecast_response_model.dart';
import 'package:weather_app/network_services.dart';

class CurrentWeatherController extends GetxController {
  RxBool isLoading = false.obs;

  var fiveDaysWeatherForecastResponseModel =
      Rxn<FiveDaysWeatherForecastResponseModel>().obs;

  var currentWeatherModel = Rxn<CurrentWeatherResponseModel>().obs;

  void getWeatherFromApi() async {
    if (!(await _checkLocationPermission())) {
      await Geolocator.requestPermission();
      getWeatherFromApi();
    } else {
      ///get current location latLng.....
      LatLng currentLocationLatLng = await _getUserLocation();

      ///five days weather from now checking from sharedPref
      fiveDaysWeatherForecastResponseModel.value.value =
          await UserDefaults.getCurrent5daysWeather();
      if (fiveDaysWeatherForecastResponseModel.value.value == null) {
        isLoading.value = true;

        ///getting weather data from the server
        fiveDaysWeatherForecastResponseModel.value.value =
            await NetworkServices.get5DaysWeatherForecast(
                latLng: currentLocationLatLng, selectedTemperatureUnit: "°C");

        ///saving to shared pref
        UserDefaults.saveCurrent5daysWeather(
            fiveDaysWeatherForecastResponseModel.value.value!);
        isLoading.value = false;
      }

      ///current weather check from the sharedPref
      currentWeatherModel.value.value = await UserDefaults.getCurrentWeather();
      if (currentWeatherModel.value.value == null) {
        isLoading.value = true;

        /// weather info getting from the server
        currentWeatherModel.value.value =
            await NetworkServices.getCurrentWeatherConditionFromLatLng(
                latLng: currentLocationLatLng, selectedTemperatureUnit: "°C");

        ///saving weather info into sharedPref
        UserDefaults.saveCurrentWeather(currentWeatherModel.value.value!);
        isLoading.value = false;
      }
    }
  }

  Future<LatLng> _getUserLocation() async {
    var position = await GeolocatorPlatform.instance.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high));

    return LatLng(position.latitude, position.longitude);
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if ((permission.name == LocationPermission.always.name) ||
        (permission.name == LocationPermission.whileInUse.name)) {
      return true;
    }
    return false;
  }
}
