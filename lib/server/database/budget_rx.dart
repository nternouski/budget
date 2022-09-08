import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../../model/budget.dart';
import '../../model/category.dart';
import '../../model/currency.dart';
import '../../model/transaction.dart';
import '../../server/database/category_rx.dart';
import '../../server/database/transaction_rx.dart';
import '../../server/database.dart';
import '../../server/database/user_rx.dart';

class BudgetRx {
  @protected
  static String collectionPath = 'budgets';
  final db = Database();

  ValueStream<List<Budget>> getBudgets(String userId, Currency? defaultCurrency) {
    String path = '${UserRx.docPath(userId)}/$collectionPath';
    return CombineLatestStream.list<List<dynamic>>([
      db.getAll(path).asyncMap((snapshot) => snapshot.toList()),
      transactionRx.getTransactions(userId, defaultCurrency),
      categoryRx.getCategories(userId)
    ]).asyncMap((list) {
      var budgetsRaw = list[0] as List<Map<String, dynamic>>;
      var transactions = list[1] as List<Transaction>;
      var categories = list[2] as List<Category>;
      return budgetsRaw.map(
        (raw) {
          Budget budget = Budget.fromJson(raw, categories, transactions);

          return budget;
        },
      ).toList();
    }).shareValue();
  }

  Future<String> create(Budget data, String userId) {
    return db.createDoc('${UserRx.docPath(userId)}/$collectionPath', data.toJson());
  }

  Future update(Budget data, String userId) {
    return db.updateDoc('${UserRx.docPath(userId)}/$collectionPath', data.toJson(), data.id);
  }

  Future delete(String id, String userId) {
    return db.deleteDoc('${UserRx.docPath(userId)}/$collectionPath', id);
  }
}

BudgetRx budgetRx = BudgetRx();
