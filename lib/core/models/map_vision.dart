import 'package:latlong2/latlong.dart';

class MapVision {
  final LatLng center;
  final double zoom;

  const MapVision({
    this.center = const LatLng(23.46999, 120.95726), // 預設中心點為玉山
    this.zoom = 7.5,
  });

  Map<String, dynamic> toMap() {
    return {
      'center': center.toJson(),
      'zoom': zoom,
    };
  }

  static MapVision? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    return MapVision(
      center: LatLng.fromJson(map['center']),
      zoom: map['zoom'],
    );
  }
}
