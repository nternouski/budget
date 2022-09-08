import 'package:flutter/material.dart';
import '../common/classes.dart';
import '../common/convert.dart';

class Category implements ModelCommonInterface {
  // ignore: non_constant_identifier_names
  static int MAX_LENGTH_NAME = 12;

  @override
  String id;
  late DateTime createdAt;
  String name;
  String iconName;
  late IconData icon;
  late Color color;

  Category({
    required this.name,
    required this.id,
    required this.iconName,
    required this.color,
    DateTime? createdAt,
  }) {
    this.createdAt = createdAt ?? DateTime.now();
    icon = Convert.toIcon(iconName);
  }

  factory Category.fromJson(
    Map<String, dynamic> json,
  ) {
    return Category(
      id: json['id'],
      createdAt: Convert.parseDate(json['createdAt']),
      name: json['name'],
      iconName: json['icon'],
      color: Convert.colorFromHex(json['color']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'createdAt': createdAt,
      'name': name,
      'icon': iconName,
      'color': Convert.colorToHexString(color)
    };
    return data;
  }
}

final defaultCategory = Category.fromJson({'name': '', 'id': '', 'icon': 'question_mark', 'color': 'FF4CAF50'});
