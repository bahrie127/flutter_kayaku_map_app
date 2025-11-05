import 'package:flutter_kayaku_map_app/data/models/auth_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDatasource {
  Future<void> saveUserInfo(AuthResponseModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_info', user.toJson());
  }

  Future<AuthResponseModel?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userInfo = prefs.getString('user_info');
    if (userInfo != null) {
      return AuthResponseModel.fromJson(userInfo);
    }
    return null;
  }

  Future<void> clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_info');
  }

  //get token from user info
  Future<String?> getToken() async {
    final userInfo = await getUserInfo();
    return userInfo?.accessToken;
  }

  //is user logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
