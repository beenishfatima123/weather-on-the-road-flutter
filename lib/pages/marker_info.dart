import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:weather_app/common/common_widgets.dart';

import 'package:weather_app/common/styles.dart';
import 'package:weather_app/controllers/google_map_controller.dart';
import 'package:weather_app/models/weather_response_model.dart';

class MarkerInfo extends StatefulWidget {
  Function getBitmapImage;
  WeatherResponseModel weatherResponseModel;
  GlobalKey markerKey = GlobalKey();

  MyGoogleMapController googleMapController = Get.find();

  MarkerInfo(
      {Key? key,
      required this.getBitmapImage,
      required this.weatherResponseModel})
      : super(key: key);

  @override
  _MarkerInfoState createState() => _MarkerInfoState();
}

class _MarkerInfoState extends State<MarkerInfo> {
  @override
  void initState() {
    super.initState();
  }

  Future<Uint8List?> getUnit8List() async {
    ByteData? byteData;
    try {
      RenderRepaintBoundary? boundary = widget.markerKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 2.0);
      byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('error taking ss');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => getUnit8List().then((markerBitmap) => {
              //    widget.getBitmapImage(markerBitmap, widget.weatherResponseModel)

              ///waiting to complete the rendring before taking a screen shot
              // Timer(
              //     const Duration(milliseconds: 500),
              //     () => {
              //
              //         })
            }));
    return RepaintBoundary(
        key: widget.markerKey,
        child: Container(
          decoration: BoxDecoration(
              color: AppColor.blackColor.withOpacity(0.4),
              shape: BoxShape.circle),
          padding: EdgeInsets.all(40.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NetworkCircularImage(
                url: (widget.weatherResponseModel.weather?[0].icon ?? "")
                        .isNotEmpty
                    ? "http://openweathermap.org/img/wn/${widget.weatherResponseModel.weather?[0].icon}@4x.png"
                    : null,
                radius: 60.r,
              ),
              Text(
                widget.weatherResponseModel.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.textStyleNormalBodyXSmall
                    .copyWith(color: AppColor.whiteColor, fontSize: 12),
              ),
              Text(
                _getTemperature(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.textStyleNormalBodyXSmall
                    .copyWith(color: AppColor.whiteColor, fontSize: 12),
              ),
              /* Text(
                widget.weatherResponseModel.weather?[0].main ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.textStyleNormalBodyXSmall
                    .copyWith(color: AppColor.whiteColor),
              ),*/
            ],
          ),
        ));
  }

  String _getTemperature() {
    var temp = (widget.weatherResponseModel.main?.temp ?? 0).toString();
    return "$temp ${widget.googleMapController.selectedTemperatureUnit.value}";
  }
}
