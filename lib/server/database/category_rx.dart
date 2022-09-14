import 'package:budget/model/category.dart';
import 'package:budget/server/database.dart';
import 'package:budget/server/database/user_rx.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class CategoryRx {
  @protected
  static String collectionPath = 'categories';
  static String getCollectionPath(String userId) => '${UserRx.docPath(userId)}/$collectionPath';
  final db = Database();

  ValueStream<List<Category>>? _categories;

  ValueStream<List<Category>> getCategories(String userId) {
    if (_categories != null) return _categories!;
    _categories = db
        .getAll(getCollectionPath(userId))
        .asyncMap((snapshot) => snapshot.map((data) => Category.fromJson(data)).toList())
        .shareValue();
    return _categories!;
  }

  Future<String> create(Category data, String userId) {
    return db.createDoc(getCollectionPath(userId), data.toJson());
  }

  Future update(Category data, String userId) {
    return db.updateDoc(getCollectionPath(userId), data.toJson(), data.id);
  }

  Future delete(String id, String userId) {
    return db.deleteDoc(getCollectionPath(userId), id);
  }
}

CategoryRx categoryRx = CategoryRx();
