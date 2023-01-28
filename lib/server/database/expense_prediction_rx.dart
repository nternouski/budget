import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../../model/expense_prediction.dart';
import '../../server/database.dart';
import '../../server/database/user_rx.dart';

class ExpensePredictionRx {
  @protected
  static String collectionPath = 'expensePredictions';
  static String getCollectionPath(String userId) => '${UserRx.docPath(userId)}/$collectionPath';
  final db = Database();

  ValueStream<List<ExpensePrediction>> getExpensePredictions(String userId) {
    return CombineLatestStream.list<List<dynamic>>([
      db.getAll(getCollectionPath(userId)).asyncMap((snapshot) => snapshot.toList()),
    ]).asyncMap((raw) {
      var rawList = raw[0] as List<Map<String, dynamic>>;
      return rawList.map((raw) => ExpensePrediction.fromJson(raw, ExpensePredictionGroup.fromJson)).toList();
    }).shareValue();
  }

  Future<String> create(ExpensePrediction data, String userId) {
    return db.createDoc(getCollectionPath(userId), data.toJson());
  }

  Future update(ExpensePrediction data, String userId) {
    return db.updateDoc(getCollectionPath(userId), data.toJson(), data.id);
  }

  Future delete(String id, String userId) {
    return db.deleteDoc(getCollectionPath(userId), id);
  }
}

ExpensePredictionRx expensePredictionRx = ExpensePredictionRx();
