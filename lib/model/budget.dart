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

  factory Budget.fromJson(Map<String, dynamic> json) {
    List<Category> categories =
        List.from(json['budget_categories']).map((c) => Category.fromJson(c['category'])).toList();

    return Budget(
      id: json['id'],
      createdAt: Convert.parseDate(json['createdAt']),
      name: json['name'],
      color: json['color'],
      amount: Convert.currencyToDouble(json['amount'], json),
      balance: -1,
      categories: categories,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'name': name,
      'color': Convert.colorToHexString(color),
      'amount': '\$$amount',
    };
    return data;
  }
}

class BudgetQueries implements GraphQlQuery {
  @override
  String getAll = '''
    query getBudgets {
      budgets {
        id
        createdAt
        amount
        color
        name
        budget_categories {
          category {
            id
            createdAt
            color
            icon
            name
          }
        }
      }
    }''';

  @override
  String create = r'''
    mutation addBudget($name: String!, $color: String!, $amount: money!) {
      action: insert_budgets(objects: [{ name: $name, color: $color, amount: $amount }]) {
        returning {
          id
          createdAt
          amount
          color
          name
          budget_categories {
            category {
              id
              createdAt
              color
              icon
              name
            }
          }
        }
      }
    }''';

  @override
  String update = r'''
    mutation updateBudget($id: uuid!, $name: String!, $color: String!, $amount: money!) {
      action: update_budgets(where: {id: {_eq: $id}}, _set: { name: $name, color: $color, amount: $amount }) {
        returning {
          id
          createdAt
          amount
          color
          name
          budget_categories {
            category {
              id
              createdAt
              color
              icon
              name
            }
          }
        }
      }
    }''';

  String insertCategories = r'''
    mutation insertCategories($budgetId: uuid!, $categoryId: uuid!) {
      action: insert_budget_categories(objects: { budgetId: $budgetId, categoryId: $categoryId }) {
        returning {
          category {
            id
            createdAt
            color
            icon
            name
          }
        }
      }
    }''';

  String deleteCategories = r'''
    mutation deleteBudget($budgetId: uuid!) {
      action: delete_budget_categories(where: { budgetId: {_eq: $budgetId} }) {
          affected_rows
      }
    }''';

  @override
  String delete = r'''
     mutation deleteBudget($id: uuid!) {
        action: delete_budgets(where: {id: {_eq: $id}} ) {
          returning {
            id
        }
      }
    }''';
}
