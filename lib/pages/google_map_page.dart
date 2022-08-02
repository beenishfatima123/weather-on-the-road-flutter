import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
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
                  screenshotDelay: const Duration(seconds: 1),
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

                          controller.customMarkers.add(
                            MarkerData(
                              marker: Marker(
                                  onTap: () {
                                    controller.openBottomSheet(
                                        weather: weatherResponseModel);
                                  },
                                  markerId: MarkerId(
                                      (weatherResponseModel.id ?? 0)
                                          .toString()),
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
                      )),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10)),
                              color: AppColor.green),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Save route',
                                style: AppTextStyles.textStyleBoldBodyMedium
                                    .copyWith(color: AppColor.whiteColor),
                              ),
                              hSpace,
                              const Icon(
                                Icons.data_saver_on,
                                color: AppColor.whiteColor,
                                size: 18,
                              )
                            ],
                          ),
                        ),
                      ),
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
