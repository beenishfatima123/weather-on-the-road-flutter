import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/common/app_pop_ups.dart';
import 'package:weather_app/common/constants.dart';
import 'package:weather_app/common/helpers.dart';
import 'package:weather_app/common/hive_db.dart';
import 'package:weather_app/common/styles.dart';
import 'package:weather_app/common/user_defaults.dart';
import 'package:weather_app/models/curent_weather_response_model.dart';
import 'package:weather_app/models/custom_weather_info_model.dart';
import 'package:weather_app/my_application.dart';
import 'package:weather_app/network_services.dart';
import 'package:weather_app/pages/current_weather_page.dart';
import 'package:weather_app/pages/weather_info_page.dart';

import '../common/app_alert_bottom_sheet.dart';
import '../common/common_widgets.dart';
import '../common/spaces_boxes.dart';
import '../pages/marker_info.dart';

List<PointLatLng> getList(int n, List<PointLatLng> source) => source.sample(n);

class RouteWeatherInfoController extends GetxController {
  RxBool isLoading = false.obs;

  ///"°F"
  var selectedTemperatureUnit = "°C".obs;

  ///lahore
  LatLng fromLocationLatLng = const LatLng(31.4779632, 74.2557278);

  ///multan30.4893914,75.0047718
  LatLng toLocationLatLng = const LatLng(30.3551585, 72.4664802);

  Set<Polyline> polylines = {};

// this will hold each polyline coordinate as Lat and Lng pairs
  List<LatLng> polylineCoordinates = [];

// this is the key object - the PolylinePoints
// which generates every polyline between start and finish
  PolylinePoints polylinePoints = PolylinePoints();
  RxSet<Marker> markers = <Marker>{}.obs;

  GoogleMapController? googleMapController;
  CameraPosition initialPosition = const CameraPosition(
    target: LatLng(31.4713968, 74.2705732),
    zoom: 14.4746,
  );

  RxList<MarkerData> customMarkers = <MarkerData>[].obs;

  CustomWeatherInfoModel? weatherInfoModel;

  Future<void> initialize(
      {required CustomWeatherInfoModel weatherInfoModel}) async {
    this.weatherInfoModel = weatherInfoModel;
    selectedTemperatureUnit.value = await UserDefaults.getWeatherUnit() ?? "°C";

    setPolyLines();
  }

  bool isZoomed = false;

  void onMapCreated(GoogleMapController controller) {
    googleMapController = controller;
    animateCameraToBounds();
  }

  setPolyLines() async {
    isLoading.value = true;
    try {
      ///adding markers
      printWrapped('list size');
      print(weatherInfoModel?.weathersList.toString());
      weatherInfoModel?.weathersList?.forEach((element) {
        printWrapped("on tapppp");
        customMarkers.add(MarkerData(
            marker: Marker(
                onTap: () {
                  openBottomSheet(weather: element);
                },
                markerId: MarkerId((element.id ?? 0).toString()),
                position: LatLng(
                    element.coord?.lat ?? 0.0, element.coord?.lon ?? 0.0)),
            child: MarkerInfo(
                getBitmapImage: (img, model) {},
                weatherResponseModel: element)));
      });

      Polyline polyline = Polyline(
          polylineId: const PolylineId("poly"),
          color: const Color.fromARGB(255, 40, 122, 198),
          points: weatherInfoModel?.polylineCoordinates
                  ?.map((e) => LatLng(
                      (e.lat ?? 0.0).toDouble(), (e.lng ?? 0.0).toDouble()))
                  .toList() ??
              []);
      polylines.add(polyline);

      isLoading.value = false;

      WidgetsBinding.instance.addPostFrameCallback((_) => {
            AppPopUps.showDialogContent(
                title: 'Long press on map to get weather information',
                dialogType: DialogType.INFO)
          });
    } catch (e) {
      printWrapped("error $e");
      isLoading.value = false;
      AppPopUps.showDialogContent(title: 'Failed to connect');
    }
  }

  void openBottomSheet({required CurrentWeatherResponseModel? weather}) {
    Get.toNamed(WeatherInfoPage.id, arguments: [
      LatLng(weather?.coord?.lat ?? 0.0, weather?.coord?.lon ?? 0.0),
      weather?.name ?? '-'
    ]);

    /* String sunRiseTime = DateFormat('hh:mm:ss').format(
        DateTime.fromMillisecondsSinceEpoch(
            (weather?.sys?.sunrise!.toInt())! * (1000)));
    String sunSetTime = DateFormat('hh:mm:ss').format(
        DateTime.fromMillisecondsSinceEpoch(
            (weather?.sys?.sunset!.toInt())! * (1000)));

    AppBottomSheets.showAppAlertBottomSheet(
      context: myContext!,
      isFull: true,
      isDismissable: true,
      title: weather?.name ?? '-',
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            vSpace,
            Row(
              children: [
                Flexible(
                  child: NetworkCircularImage(
                    url: (weather?.weather?[0].icon ?? "").isNotEmpty
                        ? "http://openweathermap.org/img/wn/${weather?.weather?[0].icon}@4x.png"
                        : null,
                    radius: 300.r,
                    bgColor: AppColor.blackColor.withOpacity(0.5),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      ("${(weather?.main?.temp ?? 0).toString()} ${selectedTemperatureUnit.value}"),
                      style: AppTextStyles.textStyleBoldTitleLarge,
                    ),
                  ),
                )
              ],
            ),
            vSpace,
            Text("Weather Condition",
                style: AppTextStyles.textStyleBoldSubTitleLarge),
            vSpace,
            keyValueRowWidget(
                title: 'Main',
                value: weather?.weather?[0].main ?? '-',
                isGrey: true),
            keyValueRowWidget(
                title: 'Description',
                value: weather?.weather?[0].description ?? '-',
                isGrey: false),
            keyValueRowWidget(
                title: 'Temp min',
                value:
                    ("${(weather?.main?.tempMin ?? 0).toString()} ${selectedTemperatureUnit.value}"),
                isGrey: true),
            keyValueRowWidget(
                title: 'Temp Max',
                value:
                    ("${(weather?.main?.tempMin ?? 0).toString()} ${selectedTemperatureUnit.value}"),
                isGrey: false),
            keyValueRowWidget(
                title: 'Pressure',
                value: ("${(weather?.main?.pressure ?? 0).toString()}  hPa"),
                isGrey: true),
            keyValueRowWidget(
                title: 'Humidity',
                value: ("${(weather?.main?.humidity ?? 0).toString()}  %"),
                isGrey: false),
            vSpace,
            Text('Visibility ${weather?.visibility ?? 0} meter',
                style: AppTextStyles.textStyleBoldSubTitleLarge),
            vSpace,
            Text('Wind', style: AppTextStyles.textStyleBoldSubTitleLarge),
            vSpace,
            keyValueRowWidget(
                title: 'Speed',
                value: "${(weather?.wind?.speed ?? 0).toString()} m/s",
                isGrey: true),
            keyValueRowWidget(
                title: 'Degree',
                value: "${(weather?.wind?.deg ?? 0).toString()} °",
                isGrey: false),
            keyValueRowWidget(
                title: 'Wind Gust',
                value: "${(weather?.wind?.gust ?? 0).toString()} m/s",
                isGrey: true),
            keyValueRowWidget(
                title: 'Cloudness',
                value: "${(weather?.clouds?.all ?? 0).toString()} %",
                isGrey: false),
            vSpace,
            Text('Sun Rise: $sunRiseTime',
                style: AppTextStyles.textStyleBoldBodyMedium),
            Text('Sun Set: $sunSetTime',
                style: AppTextStyles.textStyleBoldBodyMedium),
            vSpace,
          ],
        ),
      ),
    );*/
  }

  void animateCameraToBounds() {
    googleMapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
          LatLngBounds(
              southwest: LatLng(
                  fromLocationLatLng.latitude <= toLocationLatLng.latitude
                      ? fromLocationLatLng.latitude
                      : toLocationLatLng.latitude,
                  fromLocationLatLng.longitude <= toLocationLatLng.longitude
                      ? fromLocationLatLng.longitude
                      : toLocationLatLng.longitude),
              northeast: LatLng(
                  fromLocationLatLng.latitude <= toLocationLatLng.latitude
                      ? toLocationLatLng.latitude
                      : fromLocationLatLng.latitude,
                  fromLocationLatLng.longitude <= toLocationLatLng.longitude
                      ? toLocationLatLng.longitude
                      : fromLocationLatLng.longitude)),
          100),
    );
  }
}
