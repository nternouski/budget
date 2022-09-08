import 'package:flutter/material.dart';
import '../common/classes.dart';
import '../common/convert.dart';

class Label implements ModelCommonInterface {
  // ignore: non_constant_identifier_names
  static int MAX_LENGTH_NAME = 12;

  @override
  String id;
  late DateTime createdAt;
  String name;
  Color color;

  Label({required this.id, required this.name, required this.color, DateTime? createdAt}) {
    this.createdAt = createdAt ?? DateTime.now();
  }

  factory Label.fromJson(
    Map<String, dynamic> json,
  ) {
    return Label(
      id: json['id'],
      createdAt: Convert.parseDate(json['createdAt']),
      name: json['name'],
      color: Convert.colorFromHex(json['color']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'createdAt': createdAt,
      'name': name,
      'color': Convert.colorToHexString(color)
    };
    return data;
  }
}
