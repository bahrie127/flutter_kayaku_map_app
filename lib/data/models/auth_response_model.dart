import 'dart:convert';

import 'package:intl/intl.dart';

// {
//     "access_token": "3|hg1htTNXxXmPYj5kQY4stl44k5TefsHqhVTcYlcBc17b71bf",
//     "token_type": "Bearer",
//     "user": {
//         "id": 5,
//         "name": "Rozak",
//         "email": "rozak@gmail.com",
//         "email_verified_at": null,
//         "created_at": "2025-10-22T10:24:53.000000Z",
//         "updated_at": "2025-10-22T10:24:53.000000Z"
//     }
// }

class AuthResponseModel {
  final String accessToken;
  final String tokenType;
  final User user;

  AuthResponseModel({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  // factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
  //   return AuthResponseModel(
  //     accessToken: json['access_token'],
  //     tokenType: json['token_type'],
  //     user: User.fromJson(json['user']),
  //   );
  // }

  Map<String, dynamic> toMap() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'user': user.toMap(),
    };
  }

  factory AuthResponseModel.fromMap(Map<String, dynamic> map) {
    return AuthResponseModel(
      accessToken: map['access_token'] ?? '',
      tokenType: map['token_type'] ?? '',
      user: User.fromMap(map['user']),
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthResponseModel.fromJson(String source) =>
      AuthResponseModel.fromMap(json.decode(source));
}

class User {
  final int id;
  final String name;
  final String email;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // factory User.fromJson(Map<String, dynamic> json) {
  //   return User(
  //     id: json['id'],
  //     name: json['name'],
  //     email: json['email'],
  //     emailVerifiedAt: json['email_verified_at'] != null
  //         ? DateTime.parse(json['email_verified_at'])
  //         : null,
  //     createdAt: DateTime.parse(json['created_at']),
  //     updatedAt: DateTime.parse(json['updated_at']),
  //   );
  // }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // "created_at": "2025-10-22T10:24:53.000000Z",
  //         "updated_at": "2025-10-22T10:24:53.000000Z"
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      emailVerifiedAt: map['email_verified_at'] != null
          ? DateFormat(
              "yyyy-MM-ddTHH:mm:ss.SSSSSSZ",
            ).parse(map['email_verified_at'])
          : null,
      //"2025-10-22T10:24:53.000000Z" to DateTime
      createdAt: DateFormat(
        "yyyy-MM-ddTHH:mm:ss.SSSSSSZ",
      ).parse(map['created_at']),
      updatedAt: DateFormat(
        "yyyy-MM-ddTHH:mm:ss.SSSSSSZ",
      ).parse(map['updated_at']),
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
