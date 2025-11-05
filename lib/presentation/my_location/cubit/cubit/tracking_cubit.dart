import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kayaku_map_app/data/route_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

part 'tracking_state.dart';

class TrackingCubit extends Cubit<TrackingState> {
  final RouteService routeService;
  TrackingCubit(this.routeService) : super(TrackingProgress(false, []));

  StreamSubscription<Position>? _positionStream;

  final LocationSettings _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  Future<void> startTracking() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      emit(
        TrackingProgress(false, []),
      ); // Emit empty route points if permission denied
      return;
    }

    // Initialize with existing route points if available
    List<LatLng> routePoints = [];
    if (state is TrackingProgress) {
      routePoints = List.from((state as TrackingProgress).routePoints);
    }

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: _locationSettings,
        ).listen((Position position) {
          routePoints.add(LatLng(position.latitude, position.longitude));
          //kirim ke api atau simpan di local db
          emit(TrackingProgress(true, List.from(routePoints)));
        });
  }

  Future<void> stopTracking() async {
    await _positionStream?.cancel();
    if (state is TrackingProgress) {
      emit(TrackingProgress(false, (state as TrackingProgress).routePoints));
    } else {
      emit(TrackingProgress(false, []));
    }
  }

  Set<Polyline> getPolylines() {
    if (state is TrackingProgress) {
      return {
        Polyline(
          polylineId: const PolylineId('tracking_route'),
          points: (state as TrackingProgress).routePoints,
          color: const Color(0xFF0000FF),
          width: 5,
        ),
      };
    }
    return {};
  }

  Future<Set<Marker>> getMarkers() async {
    if (state is! TrackingProgress) return {};

    final routePoints = (state as TrackingProgress).routePoints;
    if (routePoints.isEmpty) return {};

    final BitmapDescriptor customIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/icons/flag.png',
    );

    return {
      Marker(
        markerId: const MarkerId('start_point'),
        position: routePoints.first,
        infoWindow: const InfoWindow(title: 'Start Point'),
        icon: customIcon,
      ),
      Marker(
        markerId: const MarkerId('end_point'),
        position: routePoints.last,
        infoWindow: const InfoWindow(title: 'End Point'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  //close
  @override
  Future<void> close() {
    _positionStream?.cancel();
    return super.close();
  }

  Future<void> drawRouteTo(LatLng origin, LatLng destination) async {
    //cek routepoints isempty
    // if (state is! TrackingProgress ||
    //     (state as TrackingProgress).routePoints.isEmpty) {
    //   return;
    // }
    // emit(TrackingStarted());
    final routeInfo = await routeService.getRoute(
      origin: origin,
      destination: destination,
    );

    if (routeInfo != null) {
      final updatedRoutePoints = List<LatLng>.from(
        (state as TrackingProgress).routePoints,
      )..addAll(routeInfo.points);
      emit(TrackingProgress(true, updatedRoutePoints));
    }
  }
}
