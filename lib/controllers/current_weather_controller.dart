import 'package:flutter_weather_bg_null_safety/utils/weather_type.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:weather_app/common/helpers.dart';
import 'package:weather_app/common/user_defaults.dart';
import 'package:weather_app/models/one_call_weather_response_model.dart';
import 'package:weather_app/network_services.dart';

class CurrentWeatherController extends GetxController {
  RxBool isLoading = false.obs;

  var oneCallWeatherResponseModel = Rxn<OneCallWeatherResponseModel>().obs;

  RxString weatherUnit = ''.obs;
  RxString cityName = '-'.obs;

  var backGroundWeatherType = WeatherType.hazy.obs;

  Future<void> getWeatherFromApi({bool refresh = false}) async {
    isLoading.value = true;
    weatherUnit.value = await UserDefaults.getWeatherUnit() ?? "°C";
    LatLng coord = await NetworkServices.getUserLocation();
    GeoData geoData =
        await NetworkServices.getGeoDataFromCurrentLocation(coord);
    cityName.value = geoData.city;

    ///five days weather from now checking from sharedPref
    oneCallWeatherResponseModel.value.value =
        await UserDefaults.getOneCallWeather();

    if ((oneCallWeatherResponseModel.value.value == null) || refresh) {
      isLoading.value = true;

      ///getting weather data from the server
      oneCallWeatherResponseModel.value.value =
          await NetworkServices.getOneCallWeatherFromLatLng(
              latLng: coord, selectedTemperatureUnit: "°C");
      _changeBackgroundAccordingToWeather(oneCallWeatherResponseModel
              .value.value?.current?.weather?[0].id
              ?.toInt() ??
          0);

      ///saving to shared pref
      bool result = await UserDefaults.saveOneCallWeather(
          oneCallWeatherResponseModel.value.value!);
      printWrapped("weather save result $result");
    }
    isLoading.value = false;
  }

  void _changeBackgroundAccordingToWeather(int id) {
    if ((id >= 200 && id <= 232)) {
      ///thunder Storm
      backGroundWeatherType.value = WeatherType.thunder;
    } else if ((id >= 300 && id <= 321)) {
      ///drizzle
      backGroundWeatherType.value = WeatherType.lightRainy;
    } else if ((id >= 500 && id <= 531)) {
      ///Rain
      backGroundWeatherType.value = WeatherType.heavyRainy;
    } else if ((id >= 600 && id <= 622)) {
      ///snow
      backGroundWeatherType.value = WeatherType.middleSnow;
    } else if ((id >= 701 && id <= 781)) {
      ///Atmosphere
      backGroundWeatherType.value = WeatherType.hazy;
    } else if ((id >= 801 && id <= 804)) {
      ///cloud
      backGroundWeatherType.value = WeatherType.cloudy;
    } else if (id == 800) {
      ///clear sky
      backGroundWeatherType.value = WeatherType.sunny;
    }
    printWrapped("weather ==$id: ${backGroundWeatherType.value.name}");
  }
}
