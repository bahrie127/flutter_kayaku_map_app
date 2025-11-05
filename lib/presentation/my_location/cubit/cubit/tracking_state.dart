part of 'tracking_cubit.dart';

@immutable
sealed class TrackingState {}

final class TrackingInitial extends TrackingState {}

final class TrackingStarted extends TrackingState {}

final class TrackingStopped extends TrackingState {}

final class TrackingProgress extends TrackingState {
  final bool isTracking;
  final List<LatLng> routePoints;
  TrackingProgress(this.isTracking, this.routePoints);

  //copy with
  TrackingProgress copyWith({bool? isTracking, List<LatLng>? routePoints}) {
    return TrackingProgress(
      isTracking ?? this.isTracking,
      routePoints ?? this.routePoints,
    );
  }
}
