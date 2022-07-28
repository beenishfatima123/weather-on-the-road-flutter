import 'dart:async';
import 'dart:typed_data';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:weather_app/common/app_pop_ups.dart';
import 'package:weather_app/common/helpers.dart';
import 'package:weather_app/network_services.dart';
import '../common/loading_widget.dart';
import '../common/spaces_boxes.dart';
import '../common/styles.dart';
import '../controllers/google_map_controller.dart';
import '../models/curent_weather_response_model.dart';
import 'marker_info.dart';

class GoogleMapPage extends GetView<MyGoogleMapController> {
  GoogleMapPage({Key? key}) : super(key: key);
  static const id = '/GoogleMapPage';
  final PickResult? fromLoc = Get.arguments[0];
  final PickResult? toLoc = Get.arguments[1];

  @override
  Widget build(BuildContext context) {
    //controller.isLoading.value = false;

    return Scaffold(
      appBar: myAppBar(goBack: true, title: 'Weather'),
      body: GetX<MyGoogleMapController>(
        initState: (state) {
          if ((fromLoc != null) && (toLoc != null)) {
            controller.initialize(fromLoc: fromLoc!, toLoc: toLoc!);
          }
        },
        builder: (_) {
          return SafeArea(
            child: Stack(
              children: [
                CustomGoogleMapMarkerBuilder(
                  screenshotDelay: const Duration(milliseconds: 300),
                  customMarkers: controller.customMarkers,
                  builder: (BuildContext context, Set<Marker>? markers) {
                    if (markers != null) {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        controller.markers.addAll(markers);
                      });
                    }
                    return LoadingWidget();
                  },
                ),
                Obx(() {
                  controller.markers.value;
                  return GoogleMap(
                    mapType: MapType.normal,
                    trafficEnabled: false,
                    buildingsEnabled: false,
                    myLocationEnabled: true,
                    initialCameraPosition: controller.initialPosition,
                    markers: controller.markers,
                    polylines: controller.polylines,
                    onMapCreated: controller.onMapCreated,
                    onLongPress: (LatLng latLng) async {
                      controller.isLoading.value = true;
                      CurrentWeatherResponseModel? weatherResponseModel =
                          await NetworkServices
                                  .getCurrentWeatherConditionFromLatLng(
                                      latLng: latLng,
                                      showAlert: true,
                                      selectedTemperatureUnit: controller
                                          .selectedTemperatureUnit.value) ??
                              CurrentWeatherResponseModel();

                      controller.customMarkers.add(
                        MarkerData(
                          marker: Marker(
                              onTap: () {
                                controller.openBottomSheet(
                                    weather: weatherResponseModel);
                              },
                              markerId: MarkerId(
                                  (weatherResponseModel.id ?? 0).toString()),
                              position: LatLng(
                                  weatherResponseModel.coord?.lat ?? 0.0,
                                  weatherResponseModel.coord?.lon ?? 0.0)),
                          child: MarkerInfo(
                              getBitmapImage: (img, model) {},
                              weatherResponseModel: weatherResponseModel),
                        ),
                      );
                      controller.isLoading.value = false;
                    },
                  );
                }),
                if (controller.isLoading.isTrue) LoadingWidget(),
              ],
            ),
          );
        },
      ),
    );
  }
}
