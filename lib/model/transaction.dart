import 'package:budget/model/label.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:budget/common/classes.dart';
import 'package:budget/common/convert.dart';
import 'package:budget/model/category.dart';

enum TransactionType {
  income,
  expense,
  transfer,
}

Map<TransactionType, Color> colorsTypeTransaction = {
  TransactionType.income: const Color.fromARGB(255, 0, 203, 112),
  TransactionType.expense: Colors.red[700] ?? Colors.red,
  TransactionType.transfer: Colors.grey
};

extension ParseToString on TransactionType {
  String toShortString() {
    return toString().split('.').last;
  }
}

class Transaction implements ModelCommonInterface {
  // ignore: non_constant_identifier_names
  static int MAX_LENGTH_DESCRIPTION = 80;

  @override
  String id;
  String name;
  double amount;
  double balance;
  DateTime date;
  String walletId;
  TransactionType type;
  String description;
  List<Label> labels;

  String categoryId;
  late Category category;

  Transaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.balance,
    required this.date,
    required this.walletId,
    required this.type,
    required this.description,
    required this.labels,
    required this.categoryId,
    Category? category,
  }) {
    updateBalance();
    this.category = category ?? defaultCategory;
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    List<Label> labels = List.from(json['transaction_labels']).map((c) => Label.fromJson(c['label'])).toList();
    return Transaction(
      id: json['id'],
      name: json['name'],
      amount: Convert.currencyToDouble(json['amount'], json),
      balance: 0,
      date: Convert.parseDate(json['date']),
      type: TransactionType.values.byName(json['type']),
      description: json['description'],
      labels: labels,
      category: Category.fromJson(json['category']),
      categoryId: json['categoryId'],
      walletId: json['walletId'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    updateBalance();
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'name': name,
      'date': date.toString(),
      'type': type.name,
      'amount': '\$$amount',
      'balance': '\$$balance',
      'categoryId': categoryId,
      'description': description,
      'walletId': walletId,
    };
    return data;
  }

  setTime({int hour = 0, int minute = 0}) {
    date = DateTime(date.year, date.month, date.day, hour, minute);
  }

  getTime() {
    return TimeOfDay(hour: date.hour, minute: date.minute);
  }

  String getDateFormat() {
    var now = DateTime.now();
    if (date.isBefore(now.subtract(const Duration(days: 360)))) {
      return DateFormat(DateFormat.YEAR_NUM_MONTH_DAY).format(date);
    } else if (date.isBefore(now.subtract(const Duration(days: 30)))) {
      return DateFormat(DateFormat.MONTH_DAY).format(date);
    } else if (date.isBefore(now.subtract(const Duration(days: 1)))) {
      return DateFormat(DateFormat.MONTH_WEEKDAY_DAY).format(date);
    } else {
      return DateFormat(DateFormat.HOUR24_MINUTE).format(date);
    }
  }

  void updateBalance() {
    if (type == TransactionType.expense) {
      balance = -amount;
    } else if (type == TransactionType.income) {
      balance = amount;
    } else {
      balance = 0; // Its a TransactionType.transfer
    }
  }
}

class TransactionQueries implements GraphQlQuery {
  @override
  String getAll = '''
    query getTransactions {
      transactions(where: {}) {
        id
        name
        amount
        date
        walletId
        type
        description

        categoryId
        category {
          color
          createdAt
          icon
          id
          name
        }
        transaction_labels {
          label {
            id
            createdAt
            color
            name
          }
        }
      }
    }''';

  @override
  late String create = r'''
    mutation createTransactions($name: String!, $amount: money!, $balance: money!, $date: timestamptz!, $type: String!, $description: String!, $walletId: uuid!, $categoryId: uuid!) {
      action: insert_transactions(objects: [{name: $name, amount: $amount, balance: $balance, date: $date, type: $type, description: $description, walletId: $walletId, categoryId: $categoryId }]) {
        returning {
          id
          name
          amount
          balance
          date
          type
          description
          walletId
          
          categoryId
          category {
            id
            color
            createdAt
            icon
            name
          }
          transaction_labels {
            label {
              id
              createdAt
              color
              name
            }
          }
        }
      }
    }''';

  @override
  late String update = r'''
    mutation createTransactions($id: uuid!, $name: String!, $amount: money!, $balance: money!, $date: timestamptz!, $type: String!, $description: String!, $walletId: uuid!, $categoryId: uuid!) {
      action: update_transactions(where: {id: {_eq: $id}}, _set: {name: $name, amount: $amount, balance: $balance, date: $date, type: $type, description: $description, walletId: $walletId, categoryId: $categoryId }) {
        returning {
          id
          name
          amount
          balance
          date
          type
          description
          walletId
          
          categoryId
          category {
            id
            color
            createdAt
            icon
            name
          }
          transaction_labels {
            label {
              id
              createdAt
              color
              name
            }
          }
        }
      }
    }''';

  @override
  String delete = r'''
     mutation deleteTransaction($id: uuid!) {
        action: delete_transactions(where: { id: { _eq: $id } }) {
          returning {
            id
        }
      }
    }''';

  String getBalanceAt = r'''
    query getBalanceAt($until: timestamptz!) {
      transactions_aggregate(where: {date: {_lte: $until}}) {
        aggregate {
          sum {
            balance
          }
        }
      }
    }
    ''';

  String insertLabels = r'''
    mutation insertLabels($transactionId: uuid!, $labelId: uuid!) {
      action: insert_transaction_labels(objects: { transactionId: $transactionId, labelId: $labelId }) {
        returning {
          label {
            id
            createdAt
            color
            name
          }
        }
      }
    }''';

  String deleteLabels = r'''
    mutation deleteBudget($transactionId: uuid!) {
      action: delete_transaction_labels(where: { transactionId: {_eq: $transactionId} }) {
          affected_rows
      }
    }''';
}
