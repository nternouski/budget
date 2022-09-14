import 'package:budget/common/error_handler.dart';
import 'package:budget/model/currency.dart';
import 'package:budget/model/user.dart';
import 'package:budget/server/database/currency_rx.dart';
import 'package:budget/server/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

class UserRx {
  static String collectionPath = 'users';
  static String docPath(String id) => '$collectionPath/$id';
  final db = Database();

  final user$ = BehaviorSubject<User>();
  Stream<User> get userRx => user$.stream;

  Future<String> create(User data) async {
    bool exist = await db.getDocExist(collectionPath, data.id);
    if (!exist) {
      return db.createDoc(collectionPath, data.toJson(), id: data.id);
    } else {
      return data.id;
    }
  }

  Future update(User data) {
    return db.updateDoc(collectionPath, data.toJson(), data.id);
  }

  Future delete(String id) {
    return db.deleteDoc(collectionPath, id);
  }

  Future<void> refreshUserData(String userId) async {
    try {
      final data = await db.getDocFuture(collectionPath, userId);
      String defaultCurrencyId = data['defaultCurrencyId'];
      Currency defaultCurrency = Currency.fromJson(await db.getDocFuture(CurrencyRx.collectionPath, defaultCurrencyId));
      user$.add(User.fromJson(data, defaultCurrency));
    } catch (e) {
      debugPrint(e.toString());
      throw UserException('User not created');
    }
  }
}

UserRx userRx = UserRx();
