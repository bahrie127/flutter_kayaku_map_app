part of 'location_cubit.dart';

@immutable
sealed class LocationState {}

final class LocationInitial extends LocationState {}

final class LocationLoading extends LocationState {}

final class LocationLoaded extends LocationState {
  final double latitude;
  final double longitude;
  final bool isLastKnown;
  LocationLoaded(this.latitude, this.longitude, this.isLastKnown);
}

final class LocationError extends LocationState {
  final String message;
  LocationError(this.message);
}

final class LocationPermissionDenied extends LocationState {}

final class LocationPermissionDeniedForever extends LocationState {}

final class LocationServiceDisabled extends LocationState {}
