import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:weather_app/controllers/pick_place_controller.dart';
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
  ];
}
