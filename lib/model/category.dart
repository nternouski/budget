import 'dart:developer';

import 'package:flutter/material.dart';
import '../common/classes.dart';
import '../common/color_constants.dart';
import '../common/transform.dart';

class Category implements ModelCommonInterface {
  // ignore: non_constant_identifier_names
  static int MAX_LENGTH_NAME = 12;

  @override
  String id;
  String name;
  String iconName;
  late IconData icon;
  late Color color;

  Category({required this.name, required this.id, required this.iconName, required this.color}) {
    icon = Convert.toIcon(iconName);
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      iconName: json['icon'],
      color: Convert.colorFromHex(json['color']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'name': name,
      'icon': iconName,
      'color': Convert.colorToHexString(color)
    };
    return data;
  }
}

final defaultCategory = Category.fromJson({'name': '', 'id': '', 'icon': 'question_mark', 'color': 'FF4CAF50'});

class CategoryQueries implements GraphQlQuery {
  @override
  String getAll = '''
    query getCategories {
      categories(where: {}) {
        id
        name
        icon
        color
      }
    }
    ''';

  @override
  String getById = '';

  @override
  String create = r'''
     mutation addCategory($name: String!, $icon: String!, $color: String!) {
        action: insert_categories(objects: [{ name: $name, icon: $icon, color: $color }]) {
          returning {
            id
            color
            createdAt
            icon
            name
        }
      }
    }''';

  @override
  String update = r'''
     mutation updateCategory($id: uuid!, $name: String!, $icon: String!, $color: String!) {
        action: update_categories(where: {id: {_eq: $id}}, _set: {name: $name, icon: $icon, color: $color}) {
          returning {
            id
            color
            createdAt
            icon
            name
        }
      }
    }''';

  @override
  String delete = r'''
     mutation deleteCategory($id: uuid!) {
        action: delete_categories(where: {id: {_eq: $id}} ) {
          returning {
            id
        }
      }
    }''';
}
