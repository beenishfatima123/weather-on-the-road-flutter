import 'package:get/get.dart';
import 'package:weather_app/common/hive_db.dart';
import 'package:weather_app/models/custom_weather_info_model.dart';

class SavedWeatherController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<CustomWeatherInfoModel> customWeatherList =
      <CustomWeatherInfoModel>[].obs;

  void init() async {
    isLoading.value = true;
    customWeatherList.value = await HiveDb.getListOfBoxWeather() ?? [];
    isLoading.value = false;
  }
}
