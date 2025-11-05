import 'dart:convert';

import 'package:flutter_kayaku_map_app/data/models/ritel_model.dart';

class RitelResponseModel {
  final List<RitelModel> ritels;

  RitelResponseModel({required this.ritels});

  // Factory constructor untuk membuat object dari JSON
  factory RitelResponseModel.fromJson(Map<String, dynamic> json) {
    var ritelsList = json['ritels'] as List;
    List<RitelModel> ritels =
        ritelsList.map((ritel) => RitelModel.fromJson(ritel)).toList();

    return RitelResponseModel(ritels: ritels);
  }

  // Factory constructor dari raw JSON string
  factory RitelResponseModel.fromRawJson(String str) =>
      RitelResponseModel.fromJson(json.decode(str));

  // Method untuk convert object ke JSON
  Map<String, dynamic> toJson() {
    return {
      'ritels': ritels.map((ritel) => ritel.toJson()).toList(),
    };
  }

  // Method untuk convert object ke raw JSON string
  String toRawJson() => json.encode(toJson());

  @override
  String toString() {
    return 'RitelResponseModel{ritels: ${ritels.length} items}';
  }
}
