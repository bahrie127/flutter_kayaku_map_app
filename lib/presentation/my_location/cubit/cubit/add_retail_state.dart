part of 'add_retail_cubit.dart';

@immutable
sealed class AddRetailState {}

final class AddRetailInitial extends AddRetailState {}

final class AddRetailLoading extends AddRetailState {}

final class AddRetailSuccess extends AddRetailState {
  final RitelModel ritel;

  AddRetailSuccess(this.ritel);
}

final class AddRetailError extends AddRetailState {
  final String message;

  AddRetailError(this.message);
}
