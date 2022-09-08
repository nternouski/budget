import 'package:budget/model/currency.dart';
import 'package:budget/model/wallet.dart';
import 'package:budget/server/database.dart';
import 'package:budget/server/database/currency_rx.dart';
import 'package:budget/server/database/user_rx.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class WalletRx {
  @protected
  static String collectionPath = 'wallets';
  final db = Database();

  ValueStream<List<Wallet>> getWallets(String userId) {
    String path = '${UserRx.docPath(userId)}/$collectionPath';
    return CombineLatestStream.list([
      db.getAll(path).asyncMap((snapshot) => snapshot.map((data) => Wallet.fromJson(data)).toList()),
      currencyRx.getCurrencies()
    ]).asyncMap((list) {
      var wallets = list[0] as List<Wallet>;
      var currencies = list[1] as List<Currency>;
      return wallets.map(
        (wallet) {
          wallet.currency = currencies.firstWhere((c) => c.id == wallet.currencyId);
          return wallet;
        },
      ).toList();
    }).shareValue();
  }

  Future<String> create(Wallet data, String userId) {
    return db.createDoc('${UserRx.docPath(userId)}/$collectionPath', data.toJson());
  }

  Future update(Wallet data, String userId) {
    return db.updateDoc('${UserRx.docPath(userId)}/$collectionPath', data.toJson(), data.id);
  }

  Future delete(String id, String userId) {
    return db.deleteDoc('${UserRx.docPath(userId)}/$collectionPath', id);
  }
}

WalletRx walletRx = WalletRx();
