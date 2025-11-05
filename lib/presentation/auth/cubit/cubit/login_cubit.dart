import 'package:bloc/bloc.dart';
import 'package:flutter_kayaku_map_app/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_kayaku_map_app/data/datasources/local_datasource.dart';
import 'package:flutter_kayaku_map_app/data/models/auth_response_model.dart';
import 'package:meta/meta.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRemoteDatasource authRemoteDatasource;
  LoginCubit(this.authRemoteDatasource) : super(LoginInitial());

  Future<void> login(String username, String password) async {
    emit(LoginLoading());
    final result = await authRemoteDatasource.login(username, password);
    result.fold(
      (error) => emit(LoginFailure(error)),
      (data) async {
        //simpan data ke local storage jika perlu
        await LocalDatasource().saveUserInfo(data);
        emit(LoginSuccess(data));
      }
    );
  }
}
