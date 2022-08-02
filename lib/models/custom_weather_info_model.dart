import 'dart:convert';

import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:weather_app/models/my_lat_lng.dart';

import 'curent_weather_response_model.dart';

class CustomWeatherInfoModel {
  String? id;
  List<MyLatLng>? polylineCoordinates;
  List<CurrentWeatherResponseModel>? weathersList;

//<editor-fold desc="Data Methods">

  CustomWeatherInfoModel({
    this.id,
    this.polylineCoordinates,
    this.weathersList,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomWeatherInfoModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          polylineCoordinates == other.polylineCoordinates &&
          weathersList == other.weathersList);

  @override
  int get hashCode =>
      id.hashCode ^ polylineCoordinates.hashCode ^ weathersList.hashCode;

  @override
  String toString() {
    return 'CustomWeatherInfoModel{' +
        ' id: $id,' +
        ' polylineCoordinates: $polylineCoordinates,' +
        ' weathersList: $weathersList,' +
        '}';
  }

  CustomWeatherInfoModel copyWith({
    String? id,
    List<MyLatLng>? polylineCoordinates,
    List<CurrentWeatherResponseModel>? weathersList,
  }) {
    return CustomWeatherInfoModel(
      id: id ?? this.id,
      polylineCoordinates: polylineCoordinates ?? this.polylineCoordinates,
      weathersList: weathersList ?? this.weathersList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'polylineCoordinates': polylineCoordinates?.map((element) {
        return element.toMap();
      }).toList(),
      'weathersList': weathersList?.map((e) => e.toJson()).toList(),
    };
  }

  factory CustomWeatherInfoModel.fromMap(Map<String, dynamic> map) {
    List<MyLatLng> listLatLng = [];

    map['polylineCoordinates'].forEach((e) {
      listLatLng.add(MyLatLng.fromMap(e));
    });
    List<CurrentWeatherResponseModel> listPolyCoordinates = [];

    map['weathersList'].forEach((e) {
      listPolyCoordinates.add(CurrentWeatherResponseModel.fromJson(e));
    });

    var model = CustomWeatherInfoModel(
      id: map['id'],
      polylineCoordinates: listLatLng,
      weathersList: listPolyCoordinates,
    );
    return model;
  }

//</editor-fold>
}
