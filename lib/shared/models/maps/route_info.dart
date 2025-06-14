import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteInfo {
  final List<LatLng> points;
  final String distance;
  final String duration;
  final int distanceValue;
  final int durationValue;

  RouteInfo({
    required this.points,
    required this.distance,
    required this.duration,
    required this.distanceValue,
    required this.durationValue,
  });
}
