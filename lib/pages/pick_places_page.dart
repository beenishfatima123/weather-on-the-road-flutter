import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/common/helpers.dart';
import 'package:weather_app/common/spaces_boxes.dart';
import 'package:weather_app/common/styles.dart';
import '../../../../common/loading_widget.dart';
import '../controllers/pick_place_controller.dart';
import 'google_map_page.dart';

class PickPlacePage extends GetView<PickPlaceController> {
  const PickPlacePage({Key? key}) : super(key: key);
  static const id = '/PickPlacePage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetX<PickPlaceController>(
        initState: (state) {},
        builder: (_) {
          controller.isLoading.value;
          return SafeArea(
            top: false,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Lottie.asset('assets/images/cloud_animation.json',
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: 150,
                            width: 150,
                          ),
                          vSpace,
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Track the weather and extreme weather situations along your route.",
                              style: AppTextStyles.textStyleBoldBodyMedium
                                  .copyWith(color: AppColor.whiteColor),
                            ),
                          ),
                          vSpace,
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    controller.pickUpPlace(isForStart: true);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: AppColor.primaryBlueColor),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Pick Start Point',
                                          style: AppTextStyles
                                              .textStyleBoldBodyMedium
                                              .copyWith(
                                                  color: AppColor.whiteColor),
                                        ),
                                        hSpace,
                                        const Icon(
                                          Icons.add_location_alt_outlined,
                                          color: AppColor.whiteColor,
                                          size: 18,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Text(
                                    controller.startPickResult
                                            ?.formattedAddress ??
                                        '',
                                    style: AppTextStyles
                                        .textStyleNormalBodyXSmall
                                        .copyWith(color: AppColor.green)),
                                vSpace,
                                InkWell(
                                  onTap: () {
                                    controller.pickUpPlace(isForStart: false);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: AppColor.primaryBlueColor),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Pick End Point',
                                          style: AppTextStyles
                                              .textStyleBoldBodyMedium
                                              .copyWith(
                                                  color: AppColor.whiteColor),
                                        ),
                                        hSpace,
                                        const Icon(
                                          Icons.add_location_alt_outlined,
                                          color: AppColor.whiteColor,
                                          size: 18,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Text(
                                    controller
                                            .endPickResult?.formattedAddress ??
                                        '',
                                    style: AppTextStyles
                                        .textStyleNormalBodyXSmall
                                        .copyWith(color: AppColor.green)),
                                vSpace,
                                vSpace,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if ((controller.startPickResult != null) &&
                        (controller.endPickResult != null))
                      InkWell(
                        onTap: () {
                          Get.toNamed(GoogleMapPage.id, arguments: [
                            controller.startPickResult,
                            controller.endPickResult
                          ]);
                        },
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
                                'Proceed Next',
                                style: AppTextStyles.textStyleBoldBodyMedium
                                    .copyWith(color: AppColor.whiteColor),
                              ),
                              hSpace,
                              const Icon(
                                Icons.arrow_forward,
                                color: AppColor.whiteColor,
                                size: 18,
                              )
                            ],
                          ),
                        ),
                      ),
                    if (controller.isLoading.isTrue) LoadingWidget(),
                  ],
                ),
                SizedBox(
                    height: 80,
                    child: myAppBar(
                        iconColor: AppColor.whiteColor,
                        goBack: true,
                        backGroundColor: Colors.transparent)),
              ],
            ),
          );
        },
      ),
    );
  }
}
