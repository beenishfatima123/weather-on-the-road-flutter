import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/common/styles.dart';
import 'package:weather_app/controllers/weather_info_controller.dart';
import 'package:weather_app/my_application.dart';
import 'package:weather_app/pages/pick_places_page.dart';
import 'package:weather_app/pages/weather_page_widgets.dart';

import '../../../../common/loading_widget.dart';
import '../common/spaces_boxes.dart';

class WeatherInfoPage extends GetView<WeatherInfoController>
    with WeatherWidgetMixin {
  WeatherInfoPage({Key? key}) : super(key: key);
  static const id = '/WeatherInfoPage';
  LatLng? latLng = Get.arguments?[0];
  String? cityName = Get.arguments?[1];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetX<WeatherInfoController>(
        initState: (state) {
          if (latLng != null && cityName != null) {
            controller.getWeatherFromApi(cityName: cityName!, latLng: latLng!);
          }
        },
        builder: (_) {
          return SafeArea(
            top: false,
            child: Stack(
              children: [
                ///pop up menu

                Positioned.fill(
                  child: WeatherBg(
                    weatherType: controller.backGroundWeatherType.value,
                    width: Get.width,
                    height: Get.height,
                  ),
                ),

                ///body starting from here.....
                SizedBox(
                  height: Get.height,
                  width: Get.width,
                  child: RefreshIndicator(
                    onRefresh: () {
                      if (latLng != null && cityName != null) {
                        controller.getWeatherFromApi(
                            cityName: cityName!,
                            latLng: latLng!,
                            refresh: true);
                      }
                      return Future.delayed(const Duration(milliseconds: 100));
                    },
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          SizedBox(height: Get.height * 0.15),

                          ///location name and temperature
                          Text(
                            controller.cityName.value,
                            style: AppTextStyles.textStyleNormalLargeTitle
                                .copyWith(
                                    color: AppColor.whiteColor, fontSize: 35),
                          ),
                          Text(
                            ("${controller.oneCallWeatherResponseModel.value.value?.current?.temp?.toInt() ?? 0} ${controller.weatherUnit.value}"),
                            style: AppTextStyles.textStyleNormalLargeTitle
                                .copyWith(
                                    color: AppColor.whiteColor, fontSize: 30),
                          ),
                          vSpace,

                          ///weather description
                          Text(
                            (controller.oneCallWeatherResponseModel.value.value
                                    ?.current?.weather?[0].main ??
                                "-"),
                            style: AppTextStyles.textStyleNormalBodySmall
                                .copyWith(color: AppColor.whiteColor),
                          ),

                          vSpace,
                          vSpace,

                          ///hourly weather forecast
                          Center(
                            child: ClipRect(
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                                child: Container(
                                  width: Get.width * 0.8,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade200.withAlpha(10),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      vSpace,
                                      Text(
                                        ('Current weather'),
                                        style: AppTextStyles
                                            .textStyleNormalBodySmall
                                            .copyWith(
                                                color: AppColor.whiteColor),
                                      ),
                                      vSpace,
                                      SizedBox(
                                        height: 100,
                                        child: ListView.builder(
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemCount: controller
                                                    .oneCallWeatherResponseModel
                                                    .value
                                                    .value
                                                    ?.hourly
                                                    ?.length ??
                                                0,
                                            itemBuilder: (context, index) {
                                              return getHourlyWeatherInfo(
                                                  hourlyWeather: controller
                                                      .oneCallWeatherResponseModel
                                                      .value
                                                      .value
                                                      ?.hourly?[index],
                                                  weatherUnit: controller
                                                      .weatherUnit.value);
                                            }),
                                      ),
                                      vSpace,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          vSpace,
                          vSpace,

                          ///daily weather forecast
                          Center(
                            child: ClipRect(
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                                child: Container(
                                  width: Get.width * 0.8,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade200.withAlpha(10),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      vSpace,
                                      Text(
                                        ("${controller.oneCallWeatherResponseModel.value.value?.daily?.length ?? 0} days weather forecast"),
                                        style: AppTextStyles
                                            .textStyleNormalBodySmall
                                            .copyWith(
                                                color: AppColor.whiteColor),
                                      ),
                                      Divider(
                                          color: AppColor.whiteColor
                                              .withAlpha(100)),
                                      ListView.builder(
                                          itemCount: controller
                                                  .oneCallWeatherResponseModel
                                                  .value
                                                  .value
                                                  ?.daily
                                                  ?.length ??
                                              0,
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            return getDailyWeatherForecastWidget(
                                                dailyWeather: controller
                                                    .oneCallWeatherResponseModel
                                                    .value
                                                    .value
                                                    ?.daily?[index],
                                                weatherUnit: controller
                                                    .weatherUnit.value);
                                          }),
                                      vSpace,
                                      vSpace,
                                      vSpace,
                                      StaggeredGrid.count(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                        children: [
                                          getInfoWidget(
                                            icon: Icons.hotel_class_outlined,
                                            key: "Temp.",
                                            value:
                                                ("${controller.oneCallWeatherResponseModel.value.value?.current?.temp?.toInt() ?? 0} ${controller.weatherUnit.value}"),
                                          ),
                                          getInfoWidget(
                                            icon: Icons.air,
                                            key: "Humidity",
                                            value:
                                                ("${controller.oneCallWeatherResponseModel.value.value?.current?.humidity?.toInt() ?? 0} %"),
                                          ),
                                          getInfoWidget(
                                            icon: Icons.remove_red_eye_outlined,
                                            key: "Visibility",
                                            value:
                                                ("${controller.oneCallWeatherResponseModel.value.value?.current?.visibility ?? 0} meter "),
                                          ),
                                          getInfoWidget(
                                            icon: Icons.compress,
                                            key: "Pressure",
                                            value:
                                                ("${controller.oneCallWeatherResponseModel.value.value?.current?.pressure ?? 0}  hPa"),
                                          ),
                                          getInfoWidget(
                                            icon: Icons.compress,
                                            key: "Wind Speed",
                                            value:
                                                ("${controller.oneCallWeatherResponseModel.value.value?.current?.windSpeed ?? 0}  m/s"),
                                          ),
                                          getInfoWidget(
                                            icon: Icons.cloud,
                                            key: "Clouds",
                                            value:
                                                ("${controller.oneCallWeatherResponseModel.value.value?.current?.clouds ?? 0}  %"),
                                          ),
                                          getInfoWidget(
                                            icon: Icons.sunny,
                                            key: "Sun rise",
                                            value: DateFormat('hh:mm:ss a').format(
                                                DateTime.fromMillisecondsSinceEpoch(
                                                    (controller
                                                                    .oneCallWeatherResponseModel
                                                                    .value
                                                                    .value
                                                                    ?.current
                                                                    ?.sunrise ??
                                                                0.0)
                                                            .toInt() *
                                                        (1000))),
                                          ),
                                          getInfoWidget(
                                            icon: Icons.nightlight,
                                            key: "Sun set",
                                            value: DateFormat('hh:mm:ss a').format(
                                                DateTime.fromMillisecondsSinceEpoch(
                                                    (controller
                                                                    .oneCallWeatherResponseModel
                                                                    .value
                                                                    .value
                                                                    ?.current
                                                                    ?.sunset ??
                                                                0.0)
                                                            .toInt() *
                                                        (1000))),
                                          )
                                        ],
                                      ),
                                      vSpace,
                                      vSpace,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  void _showPopupMenu() async {
    await showMenu(
      context: myContext!,
      position: RelativeRect.fromLTRB(100, 100, 100, 100),
      items: [
        PopupMenuItem<String>(child: const Text('Doge'), value: 'Doge'),
        PopupMenuItem<String>(child: const Text('Lion'), value: 'Lion'),
      ],
      elevation: 8.0,
    );
  }

  Future<void> _onPopUpMenuClick(int item) async {
    switch (item) {
      case 0:
        await Get.toNamed(PickPlacePage.id);
        break;
      case 1:
        break;
    }
  }
}
