import 'package:flutter/cupertino.dart';
import 'package:flutter_weather_bg_null_safety/utils/print_utils.dart';

import '../common/common_widgets.dart';
import '../common/helpers.dart';
import '../common/spaces_boxes.dart';
import '../common/styles.dart';
import '../models/one_call_weather_response_model.dart';

mixin WeatherWidgetMixin {
  Widget getHourlyWeatherInfo(
      {Hourly? hourlyWeather, required String weatherUnit}) {
    /* printWrapped(
        "https://openweathermap.org/img/wn/${listWeather?.weather?.first.icon ?? "10d"}@2x.png");
*/
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            getHourFromUnixTime(unixDateTime: hourlyWeather?.dt?.toInt()),
            style: AppTextStyles.textStyleNormalBodyXSmall
                .copyWith(color: AppColor.whiteColor, fontSize: 10),
          ),
          vSpace,
          Flexible(
            child: NetworkCircularImage(
                radius: 12,
                url:
                    "https://openweathermap.org/img/wn/${hourlyWeather?.weather?.first.icon ?? "10d"}@2x.png"),
          ),
          vSpace,
          Flexible(
            child: Text(
              "${hourlyWeather?.temp?.toInt() ?? 0} $weatherUnit",
              style: AppTextStyles.textStyleBoldBodyXSmall
                  .copyWith(color: AppColor.whiteColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget getDailyWeatherForecastWidget(
      {required Daily? dailyWeather, required String weatherUnit}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          /* Flexible(
            child: Text(
                getDateFromUnix(unixDateTime: dailyWeather?.dt?.toInt()),
                style: AppTextStyles.textStyleNormalBodyXSmall
                    .copyWith(color: AppColor.whiteColor)),
          ),
          hSpace,*/
          Expanded(
            flex: 4,
            child: Row(
              children: [
                NetworkCircularImage(
                    radius: 12,
                    url:
                        "https://openweathermap.org/img/wn/${dailyWeather?.weather?.first.icon ?? "10d"}@2x.png"),
                Expanded(
                  child: Text("Rain: ${dailyWeather?.rain?.toInt() ?? 0} %",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: AppTextStyles.textStyleNormalBodyXSmall
                          .copyWith(color: AppColor.whiteColor)),
                ),
                Text(
                    "${dailyWeather?.temp?.min?.toInt()}-${dailyWeather?.temp?.max?.toInt()} $weatherUnit",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: AppTextStyles.textStyleNormalBodyXSmall
                        .copyWith(color: AppColor.whiteColor)),
              ],
            ),
          ),
          hSpace,
          Text(dailyWeather?.weather?.first.description ?? '-',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: AppTextStyles.textStyleNormalBodyXSmall
                  .copyWith(color: AppColor.whiteColor)),
        ],
      ),
    );
  }

  getInfoWidget(
      {required IconData icon, required String key, required String value}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: AppColor.alphaGrey),
      child: Column(
        children: [
          Icon(icon),
          vSpace,
          Text(key, style: AppTextStyles.textStyleBoldBodyMedium),
          vSpace,
          Text(value, style: AppTextStyles.textStyleBoldBodyMedium)
        ],
      ),
    );
  }
}
