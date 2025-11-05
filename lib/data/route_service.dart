import 'package:flutter_kayaku_map_app/data/models/route_info.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteService {
  final String apiKey;
  final PolylinePoints _polylinePoints;
  RouteService(this.apiKey) : _polylinePoints = PolylinePoints(apiKey: apiKey);

  Future<RouteInfo?> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final request = RoutesApiRequest(
        origin: PointLatLng(origin.latitude, origin.longitude),
        destination: PointLatLng(destination.latitude, destination.longitude),
      );
      final response = await _polylinePoints.getRouteBetweenCoordinatesV2(
        request: request,
      );
      if (response.routes.isEmpty) {
        return null;
      }
      final route = response.routes.first;
      final List<PointLatLng> polylinePoints = route.polylinePoints ?? [];
      final points = polylinePoints
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();
      return RouteInfo(
        points: points,
        distanceKm: route.distanceMeters != null
            ? route.distanceMeters! / 1000.0
            : 0.0,
        durationMinutes: route.durationMinutes != null
            ? route.durationMinutes!.toDouble()
            : 0.0,
      );
    } catch (e) {
      print("Error fetching route: $e");
    }
    return null;
  }
}
