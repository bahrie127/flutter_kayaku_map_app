import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteInfo {
  final List<LatLng> points;
  final double distanceKm; // in meters
  final double durationMinutes;

  RouteInfo({
    required this.points,
    required this.distanceKm,
    required this.durationMinutes,
  });
}
