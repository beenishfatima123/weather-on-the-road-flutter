import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:weather_app/common/helpers.dart';
import 'package:weather_app/controllers/route_weather_info_controller.dart';
import 'package:weather_app/models/custom_weather_info_model.dart';
import 'package:weather_app/network_services.dart';

import '../common/loading_widget.dart';
import '../models/curent_weather_response_model.dart';
import 'marker_info.dart';

class RouteWeatherInfoPage extends GetView<RouteWeatherInfoController> {
  RouteWeatherInfoPage({Key? key}) : super(key: key);
  static const id = '/RouteWeatherInfoPage';
  CustomWeatherInfoModel? weatherInfoModel = Get.arguments;

  @override
  Widget build(BuildContext context) {
    //controller.isLoading.value = false;

    return Scaffold(
      appBar: myAppBar(goBack: true, title: 'Weather'),
      body: GetX<RouteWeatherInfoController>(
        initState: (state) {
          if (weatherInfoModel != null) {
            controller.initialize(weatherInfoModel: weatherInfoModel!);
          }
        },
        builder: (_) {
          return SafeArea(
            child: Stack(
              children: [
                CustomGoogleMapMarkerBuilder(
                  screenshotDelay: const Duration(seconds: 2),
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
                  return Column(
                    children: [
                      Expanded(
                          child: GoogleMap(
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

                          controller.customMarkers.add(MarkerData(
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
                          ));

                          controller.isLoading.value = false;
                        },
                      )),
                    ],
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
