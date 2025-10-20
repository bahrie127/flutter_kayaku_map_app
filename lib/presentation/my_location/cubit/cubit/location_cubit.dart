import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:geolocator/geolocator.dart';

part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(LocationInitial());

  Future<void> ensurePermissionAndGetCurrent() async {
    emit(LocationLoading());
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(LocationServiceDisabled());
      return;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // permission = await Geolocator.requestPermission();
      // if (permission == LocationPermission.denied) {
      emit(LocationPermissionDenied());
      return;
      // }
    }

    if (permission == LocationPermission.deniedForever) {
      // await Geolocator.openAppSettings();
      // await Geolocator.openLocationSettings();
      // if (permission == LocationPermission.deniedForever) {
      emit(LocationPermissionDeniedForever());
      // return;
      // }
    }

    // If permissions are granted, get the current position
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );
      emit(LocationLoaded(position.latitude, position.longitude, false));
    } catch (e) {
      // If unable to get current position, try to get last known position
      try {
        Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
        if (lastKnownPosition != null) {
          emit(
            LocationLoaded(
              lastKnownPosition.latitude,
              lastKnownPosition.longitude,
              true,
            ),
          );
        } else {
          emit(LocationError('Unable to determine location.'));
        }
      } catch (e) {
        emit(LocationError('Unable to determine location.'));
      }
    }
  }

  Future<void> requestPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      emit(LocationPermissionDenied());
      return;
    }
    if (permission == LocationPermission.deniedForever) {
      emit(LocationPermissionDeniedForever());
      return;
    }
    // If permission granted, get current location
    await ensurePermissionAndGetCurrent();
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
    refreshLocation();
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
    refreshLocation();
  }

  Future<void> refreshLocation() async {
    await ensurePermissionAndGetCurrent();
  }
}
