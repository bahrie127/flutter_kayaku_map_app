import 'package:bloc/bloc.dart';
import 'package:flutter_kayaku_map_app/data/datasources/ritel_remote_datasource.dart';
import 'package:flutter_kayaku_map_app/data/models/ritel_model.dart';
import 'package:meta/meta.dart';

part 'near_location_state.dart';

class NearLocationCubit extends Cubit<NearLocationState> {
  final RitelRemoteDatasource _ritelRemoteDatasource;

  NearLocationCubit(this._ritelRemoteDatasource) : super(NearLocationInitial());

  /// Fetch ritels by location with radius
  /// radius is in kilometers, but API expects meters
  Future<void> getRitelsByLocation({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    emit(NearLocationLoading(radiusKm: radiusKm));

    // Convert km to meters for API
    final radiusMeters = radiusKm * 1000;

    final result = await _ritelRemoteDatasource.getRitelsByLocation(
      latitude: latitude,
      longitude: longitude,
      radius: radiusMeters,
    );

    result.fold(
      (error) => emit(NearLocationError(error, radiusKm: radiusKm)),
      (ritels) => emit(NearLocationLoaded(
        ritels,
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      )),
    );
  }

  /// Increase radius by 1 km
  Future<void> increaseRadius({
    required double latitude,
    required double longitude,
  }) async {
    double currentRadius = 1.0; // default

    if (state is NearLocationLoaded) {
      currentRadius = (state as NearLocationLoaded).radiusKm;
    } else if (state is NearLocationLoading) {
      currentRadius = (state as NearLocationLoading).radiusKm;
    } else if (state is NearLocationError) {
      currentRadius = (state as NearLocationError).radiusKm;
    }

    final newRadius = currentRadius + 1.0;
    await getRitelsByLocation(
      latitude: latitude,
      longitude: longitude,
      radiusKm: newRadius,
    );
  }

  /// Decrease radius by 1 km (minimum 1 km)
  Future<void> decreaseRadius({
    required double latitude,
    required double longitude,
  }) async {
    double currentRadius = 1.0; // default

    if (state is NearLocationLoaded) {
      currentRadius = (state as NearLocationLoaded).radiusKm;
    } else if (state is NearLocationLoading) {
      currentRadius = (state as NearLocationLoading).radiusKm;
    } else if (state is NearLocationError) {
      currentRadius = (state as NearLocationError).radiusKm;
    }

    // Don't go below 1 km
    if (currentRadius <= 1.0) {
      return;
    }

    final newRadius = currentRadius - 1.0;
    await getRitelsByLocation(
      latitude: latitude,
      longitude: longitude,
      radiusKm: newRadius,
    );
  }

  /// Get current radius value
  double getCurrentRadius() {
    if (state is NearLocationLoaded) {
      return (state as NearLocationLoaded).radiusKm;
    } else if (state is NearLocationLoading) {
      return (state as NearLocationLoading).radiusKm;
    } else if (state is NearLocationError) {
      return (state as NearLocationError).radiusKm;
    }
    return 1.0; // default
  }

  /// Check if we can decrease radius (minimum is 1 km)
  bool canDecreaseRadius() {
    return getCurrentRadius() > 1.0;
  }

  /// Clear ritels data
  void clearRitels() {
    emit(NearLocationInitial());
  }
}
