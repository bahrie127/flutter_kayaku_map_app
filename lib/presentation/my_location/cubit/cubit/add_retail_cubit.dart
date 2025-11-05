import 'package:bloc/bloc.dart';
import 'package:flutter_kayaku_map_app/data/datasources/ritel_remote_datasource.dart';
import 'package:flutter_kayaku_map_app/data/models/ritel_model.dart';
import 'package:meta/meta.dart';

part 'add_retail_state.dart';

class AddRetailCubit extends Cubit<AddRetailState> {
  final RitelRemoteDatasource _ritelRemoteDatasource;

  AddRetailCubit(this._ritelRemoteDatasource) : super(AddRetailInitial());

  /// Create new retail store
  Future<void> createRitel({
    required String name,
    required String address,
    required String city,
    required double latitude,
    required double longitude,
    String? phone,
    String? province,
  }) async {
    emit(AddRetailLoading());

    final result = await _ritelRemoteDatasource.createRitel(
      name: name,
      address: address,
      city: city,
      latitude: latitude,
      longitude: longitude,
      phone: phone,
      province: province,
    );

    result.fold(
      (error) => emit(AddRetailError(error)),
      (ritel) => emit(AddRetailSuccess(ritel)),
    );
  }

  /// Reset state to initial
  void reset() {
    emit(AddRetailInitial());
  }
}
