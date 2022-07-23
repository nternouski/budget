import 'package:budget/model/currency.dart';
import 'package:flutter/material.dart';
import '../common/classes.dart';
import '../common/transform.dart';

class Budget implements ModelCommonInterface {
  @override
  String id;
  DateTime createdAt;
  String name;
  late Color color;
  double amount;
  double balance;
  String currencyId;
  Currency? currency;

  List<String> categoryIds; // FIXME: CHANGE ON DDBB
  String userId;

  Budget({
    required this.id,
    required this.createdAt,
    required this.name,
    required String color,
    required this.amount,
    required this.balance,
    required this.currencyId,
    required this.categoryIds,
    required this.userId,
  }) {
    this.color = Convert.colorFromHex(color);
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    double amount = Convert.currencyToDouble(json['amount']);
    double balance = Convert.currencyToDouble(json['transactions_aggregate']['aggregate']['sum']['balance'] ?? '\$0.0');
    return Budget(
      id: json['id'],
      createdAt: Convert.parseDate(json['createdAt']),
      name: json['name'],
      color: json['color'],
      amount: amount,
      balance: (balance * 100) / amount,
      currencyId: json['currencyId'],
      categoryIds: [],
      userId: json['userId'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'name': name,
      'color': Convert.colorToHexString(color),
      'amount': '\$$amount',
      'currencyId': currencyId,
      // 'categoryIds': categoryIds,
      'userId': userId,
    };
    return data;
  }
}

class BudgetQueries implements GraphQlQuery {
  @override
  String getAll = '''
    query getBudgets {
      budgets(where: {}) {
        id
        createdAt
        name
        color
        amount
        currencyId
        categoryId
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
     mutation addBudget($name: String!, $icon: String!, $color: String!, $initialAmount: money!, $currencyId: uuid!, $userId: uuid!) {
      action: insert_budgets(objects: [{ name: $name, icon: $icon, color: $color, initialAmount: $initialAmount, currencyId: $currencyId, userId: $userId }]) {
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
  String update = r'';

  @override
  String delete = r'';
}
