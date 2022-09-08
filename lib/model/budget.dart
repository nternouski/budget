import 'package:budget/model/transaction.dart';
import 'package:flutter/material.dart';
import '../model/category.dart';
import '../common/classes.dart';
import '../common/convert.dart';

class Budget implements ModelCommonInterface {
  // ignore: non_constant_identifier_names
  static int MAX_LENGTH_NAME = 25;

  @override
  String id;
  DateTime createdAt;
  String name;
  late Color color;
  double amount;
  double balance;
  List<Category> categories;

  Budget({
    required this.id,
    required this.createdAt,
    required this.name,
    required String color,
    required this.amount,
    required this.balance,
    required this.categories,
  }) {
    this.color = Convert.colorFromHex(color);
  }

  factory Budget.fromJson(Map<String, dynamic> json, List<Category> categories, List<Transaction> transactions) {
    List<String> categoryIds = List.from(json['categoryIds'] ?? []);
    List<Category> budgetCategories =
        categories.where((c) => categoryIds.where((id) => c.id == id).isNotEmpty).toList();
    double balance = transactions.fold(
      0.0,
      (prev, transaction) {
        if (budgetCategories.where((c) => c.id == transaction.categoryId).isNotEmpty) {
          return prev + transaction.balance;
        } else {
          return prev;
        }
      },
    );

    return Budget(
      id: json['id'],
      createdAt: Convert.parseDate(json['createdAt']),
      name: json['name'],
      color: json['color'],
      amount: Convert.currencyToDouble(json['amount'], json),
      balance: balance,
      categories: budgetCategories,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'createdAt': createdAt,
      'name': name,
      'color': Convert.colorToHexString(color),
      'amount': amount,
      'categoryIds': categories.map((c) => c.id).toList()
    };
    return data;
  }
}
