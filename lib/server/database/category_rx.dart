import 'package:budget/model/category.dart';
import 'package:budget/server/database.dart';
import 'package:budget/server/database/user_rx.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class CategoryRx {
  @protected
  static String collectionPath = 'categories';
  final db = Database();

  ValueStream<List<Category>> getCategories(String userId) {
    return db
        .getAll('${UserRx.docPath(userId)}/$collectionPath')
        .asyncMap((snapshot) => snapshot.map((data) => Category.fromJson(data)).toList())
        .shareValue();
  }

  Future<String> create(Category data, String userId) {
    return db.createDoc('${UserRx.docPath(userId)}/$collectionPath', data.toJson());
  }

  Future update(Category data, String userId) {
    return db.updateDoc('${UserRx.docPath(userId)}/$collectionPath', data.toJson(), data.id);
  }

  Future delete(String id, String userId) {
    return db.deleteDoc('${UserRx.docPath(userId)}/$collectionPath', id);
  }
}

CategoryRx categoryRx = CategoryRx();
