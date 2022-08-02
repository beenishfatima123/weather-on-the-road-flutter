import 'package:get/get.dart';
import 'package:weather_app/controllers/current_weather_controller.dart';
import 'package:weather_app/controllers/pick_place_controller.dart';
import 'package:weather_app/controllers/route_weather_info_controller.dart';
import 'package:weather_app/controllers/saved_weather_controller.dart';
import 'package:weather_app/controllers/weather_info_controller.dart';
import 'package:weather_app/pages/current_weather_page.dart';
import 'package:weather_app/pages/google_map_page.dart';
import 'package:weather_app/pages/pick_places_page.dart';
import 'package:weather_app/pages/route_weather_info_page.dart';
import 'package:weather_app/pages/weather_info_page.dart';
import '../controllers/google_map_controller.dart';
import '../pages/saved_weather_page.dart';

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
      binding: BindingsBuilder(
        () {
          Get.lazyPut<CurrentWeatherController>(
            () => CurrentWeatherController(),
          );
        },
      ),
    ),
    GetPage(
      name: WeatherInfoPage.id,
      page: () => WeatherInfoPage(),
      binding: BindingsBuilder(
        () {
          Get.lazyPut<WeatherInfoController>(
            () => WeatherInfoController(),
          );
        },
      ),
    ),
    GetPage(
      name: SavedWeatherPage.id,
      page: () => SavedWeatherPage(),
      binding: BindingsBuilder(
        () {
          Get.lazyPut<SavedWeatherController>(
            () => SavedWeatherController(),
          );
        },
      ),
    ),
    GetPage(
      name: RouteWeatherInfoPage.id,
      page: () => RouteWeatherInfoPage(),
      binding: BindingsBuilder(
        () {
          Get.lazyPut<RouteWeatherInfoController>(
            () => RouteWeatherInfoController(),
          );
        },
      ),
    ),
  ];
}
