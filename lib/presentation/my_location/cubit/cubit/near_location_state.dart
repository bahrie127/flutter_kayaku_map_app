part of 'near_location_cubit.dart';

@immutable
sealed class NearLocationState {}

final class NearLocationInitial extends NearLocationState {}

final class NearLocationLoading extends NearLocationState {
  final double radiusKm;

  NearLocationLoading({required this.radiusKm});
}

final class NearLocationLoaded extends NearLocationState {
  final List<RitelModel> ritels;
  final double latitude;
  final double longitude;
  final double radiusKm;

  NearLocationLoaded(
    this.ritels, {
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
  });
}

final class NearLocationError extends NearLocationState {
  final String message;
  final double radiusKm;

  NearLocationError(this.message, {required this.radiusKm});
}
