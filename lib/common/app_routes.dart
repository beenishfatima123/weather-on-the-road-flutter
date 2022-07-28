import 'package:get/get.dart';
import 'package:weather_app/controllers/current_weather_controller.dart';
import 'package:weather_app/controllers/pick_place_controller.dart';
import 'package:weather_app/pages/current_weather_page.dart';
import 'package:weather_app/pages/google_map_page.dart';
import 'package:weather_app/pages/pick_places_page.dart';
import '../controllers/google_map_controller.dart';

appRoutes() {
  return [
    GetPage(
        name: GoogleMapPage.id,
        page: () => GoogleMapPage(),
        binding: BindingsBuilder(() {
          Get.lazyPut<MyGoogleMapController>(
            () => MyGoogleMapController(),
          );
        })),
    GetPage(
        name: PickPlacePage.id,
        page: () => const PickPlacePage(),
        binding: BindingsBuilder(() {
          Get.lazyPut<PickPlaceController>(
            () => PickPlaceController(),
          );
        })),
    GetPage(
        name: CurrentWeatherPage.id,
        page: () => CurrentWeatherPage(),
        binding: BindingsBuilder(() {
          Get.lazyPut<CurrentWeatherController>(
            () => CurrentWeatherController(),
          );
        })),
  ];
}
