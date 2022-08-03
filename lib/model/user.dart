import '../common/classes.dart';
import '../common/transform.dart';

class User implements ModelCommonInterface {
  @override
  String id;
  DateTime createdAt;
  String name;
  String email;
  String defaultCurrencyId;

  User({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.email,
    required this.defaultCurrencyId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      createdAt: Convert.parseDate(json['createdAt']),
      name: json['name'],
      email: json['email'],
      defaultCurrencyId: json['defaultCurrencyId'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'defaultCurrencyId': defaultCurrencyId,
    };
    return data;
  }
}

class UserQueries implements GraphQlQuery {
  @override
  String getAll = r'''
    query getUsers {
      users {
        id
        createdAt
        name
        email
        defaultCurrencyId
      }
    }''';

  @override
  String getById = r'''
    query getUsers($id: uuid!) {
      action: users(where: {id: {_eq: $id}}) {
        id
        createdAt
        name
        email
        defaultCurrencyId
      }
    }''';

  @override
  String create = r'''
    mutation addUser($id: String! $name: String!, $email: String!, $defaultCurrencyId: String!) {
      action: insert_users(objects: [{ id: $id, name: $name, email: $email, defaultCurrencyId: $defaultCurrencyId }]) {
        returning {
          id
          createdAt
          name
        }
      }
    }''';

  @override
  String update = r'''
    mutation updateUser($id: String!, $name: String!, $email: String!, $defaultCurrencyId: String!) {
      action: update_users(where: {id: {_eq: $id}}, _set: { name: $name, email: $email, defaultCurrencyId: $defaultCurrencyId }) {
        returning {
          id
          createdAt
          name
        }
      }
    }''';

  @override
  String delete = r'''
     mutation deleteUser($id: String!) {
        action: delete_users(where: {id: {_eq: $id}} ) {
          returning {
            id
        }
      }
    }''';
}
