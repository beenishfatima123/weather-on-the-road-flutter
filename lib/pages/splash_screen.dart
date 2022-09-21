import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather_app/pages/current_weather_page.dart';

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
