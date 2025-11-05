import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_kayaku_map_app/data/datasources/config.dart';
import 'package:flutter_kayaku_map_app/data/models/auth_response_model.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDatasource {
  Future<Either<String, AuthResponseModel>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponseModel.fromJson(response.body);
        return Right(authResponse);
      } else {
        return Left('Login failed with status: ${response.statusCode}');
      }
    } catch (e) {
      return Left('An error occurred: $e');
    }
  }
}
