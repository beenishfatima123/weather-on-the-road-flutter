import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather_app/common/helpers.dart';
import 'package:weather_app/common/hive_db.dart';
import 'package:weather_app/common/styles.dart';
import 'package:weather_app/controllers/saved_weather_controller.dart';
import 'package:weather_app/models/custom_weather_info_model.dart';
import 'package:weather_app/pages/route_weather_info_page.dart';
import '../../../../common/loading_widget.dart';

class SavedWeatherPage extends GetView<SavedWeatherController> {
  SavedWeatherPage({Key? key}) : super(key: key);
  static const id = '/SavedWeatherPage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(goBack: true, title: 'Saved routes'),
      body: GetX<SavedWeatherController>(
        initState: (state) {
          controller.init();
        },
        builder: (_) {
          return SafeArea(
            child: Stack(
              children: [
                ListView.builder(
                    padding: const EdgeInsets.all(4),
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.customWeatherList.length,
                    itemBuilder: (context, index) {
                      return _getInfoWidget(
                          controller.customWeatherList[index]);
                    }),
                if (controller.isLoading.isTrue) LoadingWidget(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _getInfoWidget(CustomWeatherInfoModel weatherModel) {
    return InkWell(
      onTap: () {
        //HiveDb.clearDb();
        printWrapped("size");
        print(weatherModel.weathersList);
        Get.toNamed(RouteWeatherInfoPage.id, arguments: weatherModel);
      },
      child: Card(
        child: ListTile(
            title: Text(
          weatherModel.id ?? '-',
          style: AppTextStyles.textStyleBoldBodyMedium,
        )),
      ),
    );
  }
}
