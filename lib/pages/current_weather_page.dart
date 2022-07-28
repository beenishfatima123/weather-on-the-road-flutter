import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/common/styles.dart';
import '../../../../common/loading_widget.dart';
import '../common/spaces_boxes.dart';
import '../controllers/current_weather_controller.dart';

class CurrentWeatherPage extends GetView<CurrentWeatherController> {
  CurrentWeatherPage({Key? key}) : super(key: key);
  static const id = '/CurrentWeatherPage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetX<CurrentWeatherController>(
        initState: (state) {
          controller.getWeatherFromApi();
        },
        builder: (_) {
          return SafeArea(
            top: false,
            child: Stack(
              children: [
                Positioned.fill(
                  child: WeatherBg(
                    weatherType: WeatherType.thunder,
                    width: Get.width,
                    height: Get.height,
                  ),
                ),

                ///body starting from here.....
                SizedBox(
                  height: Get.height,
                  width: Get.width,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: Get.height * 0.2),
                        Text(
                          controller.currentWeatherModel.value.value?.name ??
                              "--",
                          style: AppTextStyles.textStyleNormalLargeTitle
                              .copyWith(
                                  color: AppColor.whiteColor, fontSize: 30),
                        ),
                        Text(
                          ("${controller.currentWeatherModel.value.value?.main?.temp?.toInt() ?? 0}  "),
                          style: AppTextStyles.textStyleNormalLargeTitle
                              .copyWith(
                                  color: AppColor.whiteColor, fontSize: 30),
                        ),
                        vSpace,
                        Center(
                          child: ClipRect(
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                              child: Container(
                                width: 200.0,
                                height: 200.0,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade200.withAlpha(10)),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Text((controller
                                                  .fiveDaysWeatherForecastResponseModel
                                                  .value
                                                  .value
                                                  ?.list?[0]
                                                  .dt
                                                  ?.toInt() ??
                                              1)
                                          .toString()),
                                      vSpace,
                                      Text(DateFormat('dd:MM:yy \nhh:mm:ss')
                                          .format(DateTime.fromMillisecondsSinceEpoch(
                                              // ((controller.fiveDaysWeatherForecastResponseModel
                                              //             .value.value?.list?[0].dt
                                              //             ?.toInt() ??
                                              //         1)) *
                                              (1659009600 * 1000),
                                              isUtc: true))
                                          .toString()),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (controller.isLoading.isTrue) LoadingWidget(),
              ],
            ),
          );
        },
      ),
    );
  }
}
