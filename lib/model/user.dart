import 'package:budget/model/currency.dart';
import 'package:budget/model/integration.dart';

import '../common/classes.dart';
import '../common/convert.dart';

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
  List<Integration> integrations;
  String defaultCurrencyId;
  Currency? defaultCurrency;
  double initialAmount;

  User({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.email,
    required this.integrations,
    required this.defaultCurrencyId,
    this.defaultCurrency,
    this.initialAmount = 0.0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    List<Integration> integrations = List.from(json['integrations']).map((i) => Integration.fromJson(i)).toList();
    return User(
      id: json['id'],
      createdAt: Convert.parseDate(json['createdAt']),
      name: json['name'],
      email: json['email'],
      integrations: integrations,
      defaultCurrencyId: json['defaultCurrencyId'],
      defaultCurrency: json['currency'] != null ? Currency.fromJson(json['currency']) : null,
      initialAmount: Convert.currencyToDouble(json['initialAmount'] ?? '\$ 0', json),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'defaultCurrencyId': defaultCurrencyId,
      'initialAmount': initialAmount,
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
        initialAmount

        currency {
          id
          createdAt
          name
          symbol
        }

        integrations {
          id
          createdAt
          apiKey
          integrationType
          userId
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
        initialAmount

        currency {
          id
          createdAt
          name
          symbol
        }

        integrations {
          id
          createdAt
          apiKey
          integrationType
          userId
        }
      }
    }''';

  @override
  String create = r'''
    mutation addUser($id: String!, $name: String!, $email: String!, $defaultCurrencyId: uuid!, $initialAmount: money!) {
      action: insert_users(objects: [{ id: $id, name: $name, email: $email, defaultCurrencyId: $defaultCurrencyId, initialAmount: $initialAmount }]) {
        returning {
          id
          createdAt
          name
          email
          defaultCurrencyId
          initialAmount

          currency {
            id
            createdAt
            name
            symbol
          }

          integrations {
            id
            createdAt
            apiKey
            integrationType
            userId
          }
        }
      }
    }''';

  @override
  String update = r'''
    mutation updateUser($id: String!, $name: String!, $email: String!, $defaultCurrencyId: uuid!, $initialAmount: money!) {
      action: update_users(where: {id: {_eq: $id}}, _set: { name: $name, email: $email, defaultCurrencyId: $defaultCurrencyId, initialAmount: $initialAmount }) {
        returning {
          id
          createdAt
          name
          email
          defaultCurrencyId
          initialAmount

          currency {
            id
            createdAt
            name
            symbol
          }

          integrations {
            id
            createdAt
            apiKey
            integrationType
            userId
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
