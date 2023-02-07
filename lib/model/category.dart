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
      createdAt: Convert.parseDate(json['createdAt'], json),
      name: json['name'],
      iconName: json['icon'],
      color: Convert.colorFromHex(json['color']),
    );
  }

  Category copy({
    String? id,
    String? name,
    String? iconName,
    Color? color,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
    );
  }

  void setFrom(Category category) {
    id = category.id;
    createdAt = category.createdAt;
    name = category.name;
    iconName = category.iconName;
    icon = category.icon;
    color = category.color;
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

final defaultCategory = Category(id: '', name: '', iconName: 'question_mark', color: Convert.colorFromHex('FF4CAF50'));
