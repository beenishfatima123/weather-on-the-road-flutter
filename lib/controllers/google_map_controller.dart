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
import 'package:weather_app/common/styles.dart';
import 'package:weather_app/models/weather_response_model.dart';
import 'package:weather_app/my_application.dart';

import '../common/app_alert_bottom_sheet.dart';
import '../common/common_widgets.dart';
import '../common/spaces_boxes.dart';
import '../pages/marker_info.dart';

List<PointLatLng> getList(int n, List<PointLatLng> source) => source.sample(n);

class MyGoogleMapController extends GetxController {
  RxBool isLoading = false.obs;
  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor destinationIcon;
  final dioObj = dio.Dio();

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

/*  List<MarkerData> customMarkers = [];*/
/////////////////////////////
  void initialize({required PickResult fromLoc, required PickResult toLoc}) {
    fromLocationLatLng = LatLng(fromLoc.geometry?.location.lat ?? 30.3551585,
        fromLoc.geometry?.location.lng ?? 74.2557278);
    toLocationLatLng = LatLng(toLoc.geometry?.location.lat ?? 30.3551585,
        toLoc.geometry?.location.lng ?? 74.2557278);
    setPolyLines();
  }

  bool isZoomed = false;

  void onMapCreated(GoogleMapController controller) {
    googleMapController = controller;
    /* if (!isZoomed) {
      isZoomed = true;
    }*/
    animateCameraToBounds();
  }

  setPolyLines() async {
    isLoading.value = true;
    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        AppConstants.googleMapApiKey,
        PointLatLng(fromLocationLatLng.latitude, fromLocationLatLng.longitude),
        PointLatLng(toLocationLatLng.latitude, toLocationLatLng.longitude),
      );
      if (result.points.isNotEmpty) {
        // loop through all PointLatLng points and convert them
        // to a list of LatLng, required by the Polyline
        printWrapped(result.points.first.toString());
        final splittedList = getList(result.points.length ~/ 20, result.points);
        Map<String, PointLatLng> finalMap = {"x": result.points.first};

        ///distance filter
        for (var pointLatLng in splittedList) {
          int distance = Geolocator.distanceBetween(
                  finalMap.values.last.latitude,
                  finalMap.values.last.longitude,
                  pointLatLng.latitude,
                  pointLatLng.longitude) ~/
              1000;
          if (distance > 50) {
            ///every 50 km
            finalMap[distance.toString()] = pointLatLng;
          }
        }

        printWrapped("final list size ${finalMap.entries.length}");

        ///adding markers

        for (var element in finalMap.entries) {
          LatLng latLng =
              LatLng(element.value.latitude, element.value.longitude);
          WeatherResponseModel? weatherResponseModel =
              await getWeatherConditionFromLatLng(latLng: latLng);
          customMarkers.add(MarkerData(
              marker: Marker(
                  onTap: () {
                    printWrapped("on tapppp");
                    openBottomSheet(weather: weatherResponseModel);
                  },
                  markerId:
                      MarkerId((weatherResponseModel?.id ?? 0).toString()),
                  position: LatLng(weatherResponseModel?.coord?.lat ?? 0.0,
                      weatherResponseModel?.coord?.lon ?? 0.0)),
              child: MarkerInfo(
                  getBitmapImage: (img, model) {},
                  weatherResponseModel: weatherResponseModel!)));
        }

        ///adding start and end point
        WeatherResponseModel fromWeatherResponseModel =
            await getWeatherConditionFromLatLng(latLng: fromLocationLatLng) ??
                WeatherResponseModel();
        WeatherResponseModel toWeatherResponseModel =
            await getWeatherConditionFromLatLng(latLng: toLocationLatLng) ??
                WeatherResponseModel();

        customMarkers.add(MarkerData(
            marker: Marker(
                onTap: () {
                  openBottomSheet(weather: toWeatherResponseModel);
                },
                markerId: MarkerId((toWeatherResponseModel.id ?? 0).toString()),
                position: LatLng(toWeatherResponseModel.coord?.lat ?? 0.0,
                    toWeatherResponseModel.coord?.lon ?? 0.0)),
            child: MarkerInfo(
                getBitmapImage: (img, model) {},
                weatherResponseModel: toWeatherResponseModel)));

        customMarkers.add(MarkerData(
            marker: Marker(
                onTap: () {
                  openBottomSheet(weather: fromWeatherResponseModel);
                },
                markerId:
                    MarkerId((fromWeatherResponseModel.id ?? 0).toString()),
                position: LatLng(fromWeatherResponseModel.coord?.lat ?? 0.0,
                    fromWeatherResponseModel.coord?.lon ?? 0.0)),
            child: MarkerInfo(
                getBitmapImage: (img, model) {},
                weatherResponseModel: fromWeatherResponseModel)));

        for (var point in result.points) {
          LatLng latLng = LatLng(point.latitude, point.longitude);
          polylineCoordinates.add(latLng);
        }

        Polyline polyline = Polyline(
            polylineId: const PolylineId("poly"),
            color: const Color.fromARGB(255, 40, 122, 198),
            points: polylineCoordinates);
        polylines.add(polyline);
        isLoading.value = false;

        WidgetsBinding.instance.addPostFrameCallback((_) => {
              AppPopUps.showDialogContent(
                  title: 'Long press on map to get weather information',
                  dialogType: DialogType.INFO)
            });
      } else {
        isLoading.value = false;
        print("pointssss");
        print("result point is empty");
        AppPopUps.showDialogContent(title: 'No route found');
      }
    } catch (e) {
      isLoading.value = false;
      AppPopUps.showDialogContent(title: 'Failed to connect');
    }
  }

  Future<WeatherResponseModel?> getWeatherConditionFromLatLng(
      {required LatLng latLng, bool showAlert = false}) async {
    if (showAlert) {
      isLoading.value = true;
    }
    try {
      var response = await dioObj.get(AppConstants.currentWeatherApi,
          options: dio.Options(headers: {"Content-Type": 'application/json'}),
          queryParameters: {
            "lat": latLng.latitude,
            "lon": latLng.longitude,
            "appId": AppConstants.openWeatherApiKey,
            "units":
                selectedTemperatureUnit.value == '°C' ? 'metric' : 'imperial'
          });
      if (showAlert) {
        isLoading.value = false;
      }
      if (response.statusCode == 200 && response.data != null) {
        printWrapped("got weather data...");
        printWrapped(response.data.toString());
        return WeatherResponseModel.fromJson(response.data);
      } else {
        if (showAlert) {
          AppPopUps.showDialogContent(title: 'Failed to get weather condition');
        }
        return null;
      }
    } catch (e) {
      isLoading.value = false;

      AppPopUps.showDialogContent(
          title: 'Failed to connect to server.', dialogType: DialogType.ERROR);
    }
    return null;
  }

  void addMarker(
      {BitmapDescriptor? bitMapIconDescriptor,
      required WeatherResponseModel? weatherResponseModel}) {
    markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId((weatherResponseModel?.id ?? 0).toString()),
        position: LatLng(weatherResponseModel?.coord?.lat ?? 0.0,
            weatherResponseModel?.coord?.lon ?? 0.0),
        infoWindow: InfoWindow(
            title: weatherResponseModel?.name ?? '-',
            snippet:
                "${weatherResponseModel?.weather?[0].main ?? '-'} ${weatherResponseModel?.main?.temp ?? 0} ${selectedTemperatureUnit.value}"),
        icon: bitMapIconDescriptor ?? BitmapDescriptor.defaultMarker,
        onTap: () {
          openBottomSheet(weather: weatherResponseModel);
        }));
  }

  ///to get network icon for weather condition
  Future<BitmapDescriptor> _buildMarkerIcon({required String iconName}) async {
    printWrapped("getting image");
    printWrapped(iconName);
    final http.Response response = await http
        .get(Uri.parse("http://openweathermap.org/img/wn/$iconName@4x.png"));
    BitmapDescriptor bitmapDescriptor =
        BitmapDescriptor.fromBytes(response.bodyBytes);
    // And return the product
    return bitmapDescriptor;
  }

  void openBottomSheet({required WeatherResponseModel? weather}) {
    String sunRiseTime = DateFormat('hh:mm:ss').format(
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
    );
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
