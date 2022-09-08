import 'package:budget/common/error_handler.dart';
import 'package:budget/model/currency.dart';
import 'package:budget/server/database.dart';
import 'package:budget/server/database/currency_rx.dart';
import 'package:budget/server/database/user_rx.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class CurrencyRateRx {
  @protected
  static String collectionPath = 'currencyRates';
  final db = Database();

  ValueStream<List<CurrencyRate>> getCurrencyRates(String userId) {
    return CombineLatestStream.list<List<dynamic>>([
      db.getAll('${UserRx.docPath(userId)}/$collectionPath').asyncMap((snapshot) => snapshot.toList()),
      currencyRx.getCurrencies(),
    ]).asyncMap((list) {
      var listRaw = list[0] as List<Map<String, dynamic>>;
      var categories = list[1] as List<Currency>;
      List<CurrencyRate> currencyRates = listRaw.fold(List<CurrencyRate>.from([]), (acc, raw) {
        try {
          acc.add(CurrencyRate.fromJson(raw, categories));
        } catch (error) {
          HandlerError().setError(error.toString());
        }
        return acc;
      });
      return currencyRates;
    }).shareValue();
  }

  Future<String> create(CurrencyRate data, String userId) {
    return db.createDoc('${UserRx.docPath(userId)}/$collectionPath', data.toJson());
  }

  Future update(CurrencyRate data, String userId) {
    return db.updateDoc('${UserRx.docPath(userId)}/$collectionPath', data.toJson(), data.id);
  }

  Future delete(String id, String userId) {
    return db.deleteDoc('${UserRx.docPath(userId)}/$collectionPath', id);
  }
}

CurrencyRateRx currencyRateRx = CurrencyRateRx();