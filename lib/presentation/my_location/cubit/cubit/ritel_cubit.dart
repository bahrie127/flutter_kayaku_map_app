import 'package:bloc/bloc.dart';
import 'package:flutter_kayaku_map_app/data/datasources/ritel_remote_datasource.dart';
import 'package:flutter_kayaku_map_app/data/models/ritel_model.dart';
import 'package:meta/meta.dart';

part 'ritel_state.dart';

class RitelCubit extends Cubit<RitelState> {
  final RitelRemoteDatasource _ritelRemoteDatasource;

  RitelCubit(this._ritelRemoteDatasource) : super(RitelInitial());

  /// Fetch ritels by city name
  Future<void> getRitelsByCity(String city) async {
    emit(RitelLoading());

    final result = await _ritelRemoteDatasource.getRitelsByCity(city);

    result.fold(
      (error) => emit(RitelError(error)),
      (ritels) => emit(RitelLoaded(ritels, city)),
    );
  }

  /// Refresh ritels data for the current city
  Future<void> refreshRitels() async {
    if (state is RitelLoaded) {
      final currentCity = (state as RitelLoaded).city;
      await getRitelsByCity(currentCity);
    }
  }

  /// Clear ritels data
  void clearRitels() {
    emit(RitelInitial());
  }
}
