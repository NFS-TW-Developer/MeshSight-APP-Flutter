import 'package:latlong2/latlong.dart';

class MapVision {
  final LatLng center;
  final double zoom;

  MapVision({
    required this.center,
    required this.zoom,
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
