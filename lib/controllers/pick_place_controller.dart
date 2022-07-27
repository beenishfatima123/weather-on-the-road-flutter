import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:weather_app/common/constants.dart';
import 'package:weather_app/common/helpers.dart';
import 'package:weather_app/my_application.dart';

class PickPlaceController extends GetxController {
  RxBool isLoading = false.obs;
  PickResult? startPickResult;
  PickResult? endPickResult;

  void pickUpPlace({required bool isForStart}) async {
    isLoading.value = true;
    Navigator.push(
      myContext!,
      MaterialPageRoute(
        builder: (context) => PlacePicker(
          apiKey: AppConstants.googleMapApiKey,
          onPlacePicked: (result) {
            isLoading.value = false;

            if (isForStart) {
              startPickResult = result;
            } else {
              endPickResult = result;
            }
            printWrapped("resultttt");
            printWrapped(result.formattedAddress ?? '');
            Navigator.of(context).pop();
          },
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          searchForInitialValue: true,
          usePinPointingSearch: true,
          initialPosition: const LatLng(31.2222, 73.333333),
          useCurrentLocation: true,
        ),
      ),
    );
  }
}
