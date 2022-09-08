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
  late DateTime createdAt;
  String name;
  double amount;

  /// Amount fixed with default currency of user.
  late double balanceFixed;
  double balance;
  DateTime date;
  String walletId;
  TransactionType type;
  String description;
  List<Label> labels;

  String categoryId;
  late Category category;

  String externalId;

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
    required this.externalId,
    DateTime? createdAt,
    Category? category,
  }) {
    updateBalance();
    this.createdAt = createdAt ?? DateTime.now();
    this.category = category ?? defaultCategory;
    balanceFixed = balance;
  }

  factory Transaction.fromJson(Map<String, dynamic> json, List<Label> labels) {
    return Transaction(
      id: json['id'],
      createdAt: Convert.parseDate(json['createdAt']),
      name: json['name'],
      amount: Convert.currencyToDouble(json['amount'], json),
      balance: 0,
      date: Convert.parseDate(json['date']),
      type: TransactionType.values.byName(json['type']),
      description: json['description'] ?? '',
      labels: List<String>.from(json['labelIds'] ?? [])
          .map((labelId) => labels.firstWhere((l) => labelId == l.id))
          .toList(),
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      categoryId: json['categoryId'],
      walletId: json['walletId'],
      externalId: json['externalId'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    updateBalance();
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'createdAt': createdAt,
      'name': name,
      'date': date.toString(),
      'type': type.name,
      'amount': amount,
      'balance': balance,
      'categoryId': categoryId,
      'description': description,
      'walletId': walletId,
      'externalId': externalId,
      'labelIds': labels.map((label) => label.id).toList()
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
      return DateFormat(DateFormat.ABBR_MONTH_WEEKDAY_DAY).format(date);
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
