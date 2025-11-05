part of 'ritel_cubit.dart';

@immutable
sealed class RitelState {}

final class RitelInitial extends RitelState {}

final class RitelLoading extends RitelState {}

final class RitelLoaded extends RitelState {
  final List<RitelModel> ritels;
  final String city;

  RitelLoaded(this.ritels, this.city);
}

final class RitelError extends RitelState {
  final String message;

  RitelError(this.message);
}
