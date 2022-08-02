class MyLatLng {
  num? lat;
  num? lng;

//<editor-fold desc="Data Methods">

  MyLatLng({
    this.lat,
    this.lng,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MyLatLng &&
          runtimeType == other.runtimeType &&
          lat == other.lat &&
          lng == other.lng);

  @override
  int get hashCode => lat.hashCode ^ lng.hashCode;

  @override
  String toString() {
    return 'MyLatLng{' + ' lat: $lat,' + ' lng: $lng,' + '}';
  }

  MyLatLng copyWith({
    double? lat,
    double? lng,
  }) {
    return MyLatLng(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lat': this.lat,
      'lng': this.lng,
    };
  }

  factory MyLatLng.fromMap(Map<String, dynamic> map) {
    return MyLatLng(
      lat: map['lat'],
      lng: map['lng'],
    );
  }

//</editor-fold>
}
