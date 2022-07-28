import 'dart:developer';

import 'package:budget/model/category.dart';
import 'package:budget/model/currency.dart';
import 'package:flutter/material.dart';
import '../common/classes.dart';
import '../common/transform.dart';

class Wallet implements ModelCommonInterface {
  // ignore: non_constant_identifier_names
  static int MAX_LENGTH_NAME = 15;

  @override
  String id;
  DateTime createdAt;
  String name;
  late Color color;
  late IconData icon;
  String iconName;
  double initialAmount;
  double balance;
  String currencyId;
  Currency? currency;
  String userId;

  Wallet({
    required this.id,
    required this.createdAt,
    required this.name,
    required String color,
    required this.iconName,
    required this.initialAmount,
    required this.balance,
    required this.userId,
    required this.currencyId,
  }) {
    icon = Convert.toIcon(iconName);
    this.color = Convert.colorFromHex(color);
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    double initialAmount = Convert.currencyToDouble(json['initialAmount']);
    double balance = Convert.currencyToDouble(json['transactions_aggregate']['aggregate']['sum']['balance'] ?? '\$0.0');
    return Wallet(
      id: json['id'],
      createdAt: Convert.parseDate(json['createdAt']),
      name: json['name'],
      color: json['color'],
      iconName: json['icon'],
      initialAmount: initialAmount,
      balance: initialAmount + balance,
      currencyId: json['currencyId'],
      userId: json['userId'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'name': name,
      'color': Convert.colorToHexString(color),
      'icon': iconName,
      'initialAmount': '\$$initialAmount',
      'currencyId': currencyId,
      // 'userId': userId,
    };
    return data;
  }
}

class WalletQueries implements GraphQlQuery {
  @override
  String getAll = '''
    query getWallets {
      wallets(where: {}) {
        id
        createdAt
        name
        color
        icon
        initialAmount
        currencyId
        userId
        transactions_aggregate {
          aggregate {
            sum {
              balance
            }
          }
        }
      }
    }''';

  @override
  String getById = '';

  @override
  String create = r'''
     mutation addWallet($name: String!, $icon: String!, $color: String!, $initialAmount: money!, $currencyId: uuid!, $userId: uuid!) {
      action: insert_wallets(objects: [{ name: $name, icon: $icon, color: $color, initialAmount: $initialAmount, currencyId: $currencyId, userId: $userId }]) {
        returning {
          id
          createdAt
          name
          color
          icon
          initialAmount
          currencyId
          userId
          transactions_aggregate {
            aggregate {
              sum {
                balance
              }
            }
          }
        }
      }
    }''';

  @override
  String update = r'''
     mutation updateWallet($id: uuid!, $name: String!, $icon: String!, $color: String!, $initialAmount: money!, $currencyId: uuid!) {
      action: update_wallets(where: {id: {_eq: $id}}, _set: { name: $name, icon: $icon, color: $color, initialAmount: $initialAmount, currencyId: $currencyId }) {
        returning {
          id
          createdAt
          name
          color
          icon
          initialAmount
          currencyId
          userId
          transactions_aggregate {
            aggregate {
              sum {
                balance
              }
            }
          }
        }
      }
    }''';

  @override
  String delete = r'''
     mutation deleteWallet($id: uuid!) {
        action: delete_categories(where: {id: {_eq: $id}}, ) {
          returning {
            id
        }
      }
    }''';
}
