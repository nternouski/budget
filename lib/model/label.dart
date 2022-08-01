import 'package:flutter/material.dart';
import '../common/classes.dart';
import '../common/transform.dart';

class Label implements ModelCommonInterface {
  // ignore: non_constant_identifier_names
  static int MAX_LENGTH_NAME = 12;

  @override
  String id;
  String name;
  Color color;

  Label({required this.id, required this.name, required this.color});

  factory Label.fromJson(Map<String, dynamic> json) {
    return Label(
      id: json['id'],
      name: json['name'],
      color: Convert.colorFromHex(json['color']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'name': name,
      'color': Convert.colorToHexString(color)
    };
    return data;
  }
}

class LabelQueries implements GraphQlQuery {
  @override
  String getAll = '''
    query getLabels {
      labels(where: {}) {
        id
        name
        color
      }
    }
    ''';

  @override
  String getById = '';

  @override
  String create = r'''
     mutation addLabel($name: String!, $color: String!) {
        action: insert_labels(objects: [{ name: $name, color: $color }]) {
          returning {
            id
            createdAt
            color
            name
        }
      }
    }''';

  @override
  String update = r'''
     mutation updateLabel($id: uuid!, $name: String!, $color: String!) {
        action: update_labels(where: {id: {_eq: $id}}, _set: {name: $name, color: $color}) {
          returning {
            id
            createdAt
            color
            name
        }
      }
    }''';

  @override
  String delete = r'''
     mutation deleteLabel($id: uuid!) {
        action: delete_labels(where: {id: {_eq: $id}} ) {
          returning {
            id
        }
      }
    }''';
}
