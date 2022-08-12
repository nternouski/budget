import 'package:budget/model/currency.dart';

import '../common/classes.dart';
import '../common/transform.dart';

class Token {
  String idToken;
  String role;
  String userId;
  String name;
  String picture;
  String email;
  bool emailVerified;
  bool logged;

  Token({
    required this.idToken,
    required this.role,
    required this.userId,
    required this.name,
    required this.picture,
    required this.email,
    required this.emailVerified,
    required this.logged,
  });

  factory Token.fromJson(String idToken, Map<String, dynamic> json) {
    return Token(
      idToken: idToken,
      role: json['https://hasura.io/jwt/claims']['x-hasura-default-role'],
      userId: json['https://hasura.io/jwt/claims']['x-hasura-user-id'],
      name: json['name'] ?? '',
      picture: json['picture'] ?? '',
      email: json['email'] ?? '',
      emailVerified: json['email_verified'] ?? false,
      logged: true,
    );
  }

  factory Token.init() {
    return Token(
      idToken: '',
      role: '',
      userId: '',
      name: '',
      picture: '',
      email: '',
      emailVerified: false,
      logged: false,
    );
  }

  bool isLogged() => logged;
}

class User implements ModelCommonInterface {
  @override
  String id;
  DateTime createdAt;
  String name;
  String email;
  String defaultCurrencyId;
  Currency? defaultCurrency;

  User({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.email,
    required this.defaultCurrencyId,
    this.defaultCurrency,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      createdAt: Convert.parseDate(json['createdAt']),
      name: json['name'],
      email: json['email'],
      defaultCurrencyId: json['defaultCurrencyId'],
      defaultCurrency: json['currency'] != null ? Currency.fromJson(json['currency']) : null,
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

        currency {
          id
          createdAt
          name
          symbol
        }
      }
    }''';

  String getUser = r'''
    query getUsers($id: String!) {
      users( where: {id: {_eq: $id}} ){
        id
        createdAt
        name
        email
        defaultCurrencyId

        currency {
          id
          createdAt
          name
          symbol
        }
      }
    }''';

  @override
  String create = r'''
    mutation addUser($id: String!, $name: String!, $email: String!, $defaultCurrencyId: uuid!) {
      action: insert_users(objects: [{ id: $id, name: $name, email: $email, defaultCurrencyId: $defaultCurrencyId }]) {
        returning {
          id
          createdAt
          name
          email
          defaultCurrencyId

          currency {
            id
            createdAt
            name
            symbol
          }
        }
      }
    }''';

  @override
  String update = r'''
    mutation updateUser($id: String!, $name: String!, $email: String!, $defaultCurrencyId: uuid!) {
      action: update_users(where: {id: {_eq: $id}}, _set: { name: $name, email: $email, defaultCurrencyId: $defaultCurrencyId }) {
        returning {
          id
          createdAt
          name
          email
          defaultCurrencyId

          currency {
            id
            createdAt
            name
            symbol
          }
        }
      }
    }''';

  @override
  String delete = r'''
    mutation deleteUser($id: String!) {
      action: delete_users(id: $id) {
        affected_rows
      }
    }''';
}
