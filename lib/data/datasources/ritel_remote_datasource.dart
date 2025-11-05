import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:flutter_kayaku_map_app/data/datasources/config.dart';
import 'package:flutter_kayaku_map_app/data/datasources/local_datasource.dart';
import 'package:flutter_kayaku_map_app/data/models/ritel_model.dart';
import 'package:flutter_kayaku_map_app/data/models/ritel_response_model.dart';
import 'package:http/http.dart' as http;

class RitelRemoteDatasource {
  final LocalDatasource localDatasource = LocalDatasource();

  /// Get ritels by city
  /// Returns `Either<String, List<RitelModel>>`
  /// Left: error message
  /// Right: list of ritels
  Future<Either<String, List<RitelModel>>> getRitelsByCity(String city) async {
    try {
      // Get token from local datasource
      final token = await localDatasource.getToken();

      if (token == null || token.isEmpty) {
        return const Left('Token not found. Please login first.');
      }

      // Encode city name untuk URL
      final encodedCity = Uri.encodeComponent(city);
      final url = Uri.parse('${Config.baseUrl}/api/ritels?city=$encodedCity');

      developer.log('🌐 Request URL: $url', name: 'RitelRemoteDatasource');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      developer.log(
        '📡 Response Status: ${response.statusCode}',
        name: 'RitelRemoteDatasource',
      );
      developer.log(
        '📦 Response Body: ${response.body}',
        name: 'RitelRemoteDatasource',
      );

      if (response.statusCode == 200) {
        try {
          // Parse JSON response
          final jsonResponse = json.decode(response.body);
          developer.log(
            '✅ JSON Decoded Successfully',
            name: 'RitelRemoteDatasource',
          );

          // Parse to model
          final ritelResponse = RitelResponseModel.fromJson(jsonResponse);
          developer.log(
            '✅ Model Parsed Successfully: ${ritelResponse.ritels.length} ritels',
            name: 'RitelRemoteDatasource',
          );

          return Right(ritelResponse.ritels);
        } on FormatException catch (e, stackTrace) {
          developer.log(
            '❌ JSON PARSING ERROR: $e\nResponse Body: ${response.body}',
            name: 'RitelRemoteDatasource',
            error: e,
            stackTrace: stackTrace,
          );
          return Left('JSON parsing error: ${e.message}. Body: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...');
        } catch (e, stackTrace) {
          developer.log(
            '❌ MODEL PARSING ERROR: $e\nResponse Body: ${response.body}',
            name: 'RitelRemoteDatasource',
            error: e,
            stackTrace: stackTrace,
          );
          return Left('Model parsing error: $e');
        }
      } else if (response.statusCode == 401) {
        developer.log(
          '🔒 Unauthorized',
          name: 'RitelRemoteDatasource',
        );
        return const Left('Unauthorized. Please login again.');
      } else if (response.statusCode == 400) {
        try {
          final jsonResponse = json.decode(response.body);
          final message = jsonResponse['message'] ?? 'Bad request';
          developer.log(
            '⚠️ Bad Request: $message',
            name: 'RitelRemoteDatasource',
          );
          return Left(message);
        } catch (e) {
          developer.log(
            '⚠️ Bad Request (unable to parse message)',
            name: 'RitelRemoteDatasource',
          );
          return Left('Bad request. Response: ${response.body}');
        }
      } else {
        developer.log(
          '❌ HTTP Error: ${response.statusCode}\nResponse: ${response.body}',
          name: 'RitelRemoteDatasource',
        );
        return Left('Failed to load ritels: ${response.statusCode}. Response: ${response.body}');
      }
    } catch (e, stackTrace) {
      developer.log(
        '❌ GENERAL ERROR in getRitelsByCity: $e',
        name: 'RitelRemoteDatasource',
        error: e,
        stackTrace: stackTrace,
      );
      return Left('An error occurred: $e');
    }
  }

  /// Get ritels by city using path parameter (alternative endpoint)
  /// Returns `Either<String, List<RitelModel>>`
  /// Left: error message
  /// Right: list of ritels
  Future<Either<String, List<RitelModel>>> getRitelsByCityPath(
      String city) async {
    try {
      // Get token from local datasource
      final token = await localDatasource.getToken();

      if (token == null || token.isEmpty) {
        return const Left('Token not found. Please login first.');
      }

      final encodedCity = Uri.encodeComponent(city);
      final url =
          Uri.parse('${Config.baseUrl}/api/ritels/city/$encodedCity');

      developer.log('🌐 Request URL: $url', name: 'RitelRemoteDatasource');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      developer.log(
        '📡 Response Status: ${response.statusCode}',
        name: 'RitelRemoteDatasource',
      );
      developer.log(
        '📦 Response Body: ${response.body}',
        name: 'RitelRemoteDatasource',
      );

      if (response.statusCode == 200) {
        try {
          // Parse JSON response
          final jsonResponse = json.decode(response.body);
          developer.log(
            '✅ JSON Decoded Successfully',
            name: 'RitelRemoteDatasource',
          );

          // Parse to model
          final ritelResponse = RitelResponseModel.fromJson(jsonResponse);
          developer.log(
            '✅ Model Parsed Successfully: ${ritelResponse.ritels.length} ritels',
            name: 'RitelRemoteDatasource',
          );

          return Right(ritelResponse.ritels);
        } on FormatException catch (e, stackTrace) {
          developer.log(
            '❌ JSON PARSING ERROR: $e\nResponse Body: ${response.body}',
            name: 'RitelRemoteDatasource',
            error: e,
            stackTrace: stackTrace,
          );
          return Left('JSON parsing error: ${e.message}. Body: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...');
        } catch (e, stackTrace) {
          developer.log(
            '❌ MODEL PARSING ERROR: $e\nResponse Body: ${response.body}',
            name: 'RitelRemoteDatasource',
            error: e,
            stackTrace: stackTrace,
          );
          return Left('Model parsing error: $e');
        }
      } else if (response.statusCode == 401) {
        developer.log(
          '🔒 Unauthorized',
          name: 'RitelRemoteDatasource',
        );
        return const Left('Unauthorized. Please login again.');
      } else {
        developer.log(
          '❌ HTTP Error: ${response.statusCode}\nResponse: ${response.body}',
          name: 'RitelRemoteDatasource',
        );
        return Left('Failed to load ritels: ${response.statusCode}. Response: ${response.body}');
      }
    } catch (e, stackTrace) {
      developer.log(
        '❌ GENERAL ERROR in getRitelsByCityPath: $e',
        name: 'RitelRemoteDatasource',
        error: e,
        stackTrace: stackTrace,
      );
      return Left('An error occurred: $e');
    }
  }

  /// Get ritels by location (latitude, longitude, radius)
  /// Returns `Either<String, List<RitelModel>>`
  /// Left: error message
  /// Right: list of ritels
  /// radius parameter is in meters (e.g., 1000 = 1km)
  Future<Either<String, List<RitelModel>>> getRitelsByLocation({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    try {
      // Get token from local datasource
      final token = await localDatasource.getToken();

      if (token == null || token.isEmpty) {
        return const Left('Token not found. Please login first.');
      }

      final url = Uri.parse('${Config.baseUrl}/api/ritels/by-location');

      developer.log('🌐 Request URL: $url', name: 'RitelRemoteDatasource');
      developer.log(
        '📍 Location: lat=$latitude, lng=$longitude, radius=$radius meters',
        name: 'RitelRemoteDatasource',
      );

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        }),
      );

      developer.log(
        '📡 Response Status: ${response.statusCode}',
        name: 'RitelRemoteDatasource',
      );
      developer.log(
        '📦 Response Body: ${response.body}',
        name: 'RitelRemoteDatasource',
      );

      if (response.statusCode == 200) {
        try {
          // Parse JSON response
          final jsonResponse = json.decode(response.body);
          developer.log(
            '✅ JSON Decoded Successfully',
            name: 'RitelRemoteDatasource',
          );

          // Parse to model
          final ritelResponse = RitelResponseModel.fromJson(jsonResponse);
          developer.log(
            '✅ Model Parsed Successfully: ${ritelResponse.ritels.length} ritels',
            name: 'RitelRemoteDatasource',
          );

          return Right(ritelResponse.ritels);
        } on FormatException catch (e, stackTrace) {
          developer.log(
            '❌ JSON PARSING ERROR: $e\nResponse Body: ${response.body}',
            name: 'RitelRemoteDatasource',
            error: e,
            stackTrace: stackTrace,
          );
          return Left('JSON parsing error: ${e.message}');
        } catch (e, stackTrace) {
          developer.log(
            '❌ MODEL PARSING ERROR: $e\nResponse Body: ${response.body}',
            name: 'RitelRemoteDatasource',
            error: e,
            stackTrace: stackTrace,
          );
          return Left('Model parsing error: $e');
        }
      } else if (response.statusCode == 401) {
        developer.log(
          '🔒 Unauthorized',
          name: 'RitelRemoteDatasource',
        );
        return const Left('Unauthorized. Please login again.');
      } else if (response.statusCode == 400 || response.statusCode == 422) {
        try {
          final jsonResponse = json.decode(response.body);
          final message = jsonResponse['message'] ?? 'Bad request';
          developer.log(
            '⚠️ Bad Request: $message',
            name: 'RitelRemoteDatasource',
          );
          return Left(message);
        } catch (e) {
          developer.log(
            '⚠️ Bad Request (unable to parse message)',
            name: 'RitelRemoteDatasource',
          );
          return Left('Bad request. Response: ${response.body}');
        }
      } else {
        developer.log(
          '❌ HTTP Error: ${response.statusCode}\nResponse: ${response.body}',
          name: 'RitelRemoteDatasource',
        );
        return Left('Failed to load ritels: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      developer.log(
        '❌ GENERAL ERROR in getRitelsByLocation: $e',
        name: 'RitelRemoteDatasource',
        error: e,
        stackTrace: stackTrace,
      );
      return Left('An error occurred: $e');
    }
  }

  /// Create new ritel
  /// Returns `Either<String, RitelModel>`
  /// Left: error message
  /// Right: created ritel
  Future<Either<String, RitelModel>> createRitel({
    required String name,
    required String address,
    required String city,
    required double latitude,
    required double longitude,
    String? phone,
    String? province,
  }) async {
    try {
      // Get token from local datasource
      final token = await localDatasource.getToken();

      if (token == null || token.isEmpty) {
        return const Left('Token not found. Please login first.');
      }

      final url = Uri.parse('${Config.baseUrl}/api/ritels');

      developer.log('🌐 Request URL: $url', name: 'RitelRemoteDatasource');
      developer.log(
        '📝 Creating ritel: $name at $city',
        name: 'RitelRemoteDatasource',
      );

      final body = {
        'name': name,
        'address': address,
        'city': city,
        'latitude': latitude,
        'longitude': longitude,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (province != null && province.isNotEmpty) 'province': province,
      };

      developer.log(
        '📦 Request Body: ${json.encode(body)}',
        name: 'RitelRemoteDatasource',
      );

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      developer.log(
        '📡 Response Status: ${response.statusCode}',
        name: 'RitelRemoteDatasource',
      );
      developer.log(
        '📦 Response Body: ${response.body}',
        name: 'RitelRemoteDatasource',
      );

      if (response.statusCode == 201) {
        try {
          // Parse JSON response
          final jsonResponse = json.decode(response.body);
          developer.log(
            '✅ JSON Decoded Successfully',
            name: 'RitelRemoteDatasource',
          );

          // Parse to model
          final ritel = RitelModel.fromJson(jsonResponse['ritel']);
          developer.log(
            '✅ Ritel Created Successfully: ${ritel.name}',
            name: 'RitelRemoteDatasource',
          );

          return Right(ritel);
        } on FormatException catch (e, stackTrace) {
          developer.log(
            '❌ JSON PARSING ERROR: $e\nResponse Body: ${response.body}',
            name: 'RitelRemoteDatasource',
            error: e,
            stackTrace: stackTrace,
          );
          return Left('JSON parsing error: ${e.message}');
        } catch (e, stackTrace) {
          developer.log(
            '❌ MODEL PARSING ERROR: $e\nResponse Body: ${response.body}',
            name: 'RitelRemoteDatasource',
            error: e,
            stackTrace: stackTrace,
          );
          return Left('Model parsing error: $e');
        }
      } else if (response.statusCode == 401) {
        developer.log(
          '🔒 Unauthorized',
          name: 'RitelRemoteDatasource',
        );
        return const Left('Unauthorized. Please login again.');
      } else if (response.statusCode == 422) {
        try {
          final jsonResponse = json.decode(response.body);
          final message = jsonResponse['message'] ?? 'Validation error';
          final errors = jsonResponse['errors'] as Map<String, dynamic>?;

          if (errors != null) {
            // Collect all error messages
            final errorMessages = <String>[];
            errors.forEach((field, messages) {
              if (messages is List) {
                errorMessages.addAll(messages.map((m) => '$field: $m'));
              }
            });
            developer.log(
              '⚠️ Validation Errors: ${errorMessages.join(', ')}',
              name: 'RitelRemoteDatasource',
            );
            return Left(errorMessages.join('\n'));
          }

          developer.log(
            '⚠️ Validation Error: $message',
            name: 'RitelRemoteDatasource',
          );
          return Left(message);
        } catch (e) {
          developer.log(
            '⚠️ Validation Error (unable to parse message)',
            name: 'RitelRemoteDatasource',
          );
          return Left('Validation error. Response: ${response.body}');
        }
      } else {
        developer.log(
          '❌ HTTP Error: ${response.statusCode}\nResponse: ${response.body}',
          name: 'RitelRemoteDatasource',
        );
        return Left('Failed to create ritel: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      developer.log(
        '❌ GENERAL ERROR in createRitel: $e',
        name: 'RitelRemoteDatasource',
        error: e,
        stackTrace: stackTrace,
      );
      return Left('An error occurred: $e');
    }
  }
}
