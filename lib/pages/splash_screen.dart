import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:weather_app/network_services.dart';
import 'package:weather_app/pages/current_weather_page.dart';
import 'package:weather_app/pages/pick_places_page.dart';

import '../common/constants.dart';
import 'google_map_page.dart';

class SplashScreen extends StatefulWidget {
  static const id = "/SplashScreen";

  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () => {gotoRelevantScreenOnUserType()});
  }

  void gotoRelevantScreenOnUserType() async {
    Get.offNamed(CurrentWeatherPage.id);

    /* var result = await NetworkServices.checkLocationPermission();

    if (result) {
      LatLng currentLocationLatLng = await NetworkServices.getUserLocation();
      GeoData geoData = await NetworkServices.getGeoDataFromCurrentLocation(
          currentLocationLatLng);

      ///getting current city Name;
      String cityName = geoData.city;
      LatLng latLng = LatLng(geoData.latitude, geoData.longitude);
      Get.offNamed(CurrentWeatherPage.id, arguments: [latLng, cityName]);
    } else {
      await Geolocator.requestPermission();
      gotoRelevantScreenOnUserType();
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(38.0),
          child: Image.asset("assets/images/logo.png"),
        ),
      ),
    );
  }
}
