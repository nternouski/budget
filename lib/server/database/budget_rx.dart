import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../../model/budget.dart';
import '../../model/category.dart';
import '../../model/transaction.dart';
import '../../server/database/category_rx.dart';
import '../../server/database/transaction_rx.dart';
import '../../server/database.dart';
import '../../server/database/user_rx.dart';

class BudgetRx {
  @protected
  static String collectionPath = 'budgets';
  static String getCollectionPath(String userId) => '${UserRx.docPath(userId)}/$collectionPath';
  final db = Database();

  ValueStream<List<Budget>> getBudgets(String userId) {
    return CombineLatestStream.list<List<dynamic>>([
      db.getAll(getCollectionPath(userId)).asyncMap((snapshot) => snapshot.toList()),
      transactionRx.getTransactions(userId),
      categoryRx.getCategories(userId)
    ]).asyncMap((list) {
      var budgetsRaw = list[0] as List<Map<String, dynamic>>;
      var transactions = list[1] as List<Transaction>;
      var categories = list[2] as List<Category>;
      return budgetsRaw.map((raw) => Budget.fromJson(raw, categories, transactions)).toList();
    }).shareValue();
  }

  Future<String> create(Budget data, String userId) {
    return db.createDoc(getCollectionPath(userId), data.toJson());
  }

  Future update(Budget data, String userId) {
    return db.updateDoc(getCollectionPath(userId), data.toJson(), data.id);
  }

  Future delete(String id, String userId) {
    return db.deleteDoc(getCollectionPath(userId), id);
  }
}

BudgetRx budgetRx = BudgetRx();
