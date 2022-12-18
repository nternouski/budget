import 'package:budget/server/database/transaction_rx.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'package:budget/model/currency.dart';
import 'package:budget/model/wallet.dart';
import 'package:budget/server/database.dart';
import 'package:budget/server/database/currency_rx.dart';
import 'package:budget/server/database/user_rx.dart';

class WalletRx {
  @protected
  static String collectionPath = 'wallets';
  static String getCollectionPath(String userId) => '${UserRx.docPath(userId)}/$collectionPath';
  final db = Database();

  ValueStream<List<Wallet>>? _wallets;

  Future<Wallet> getDocFuture(String id, String userId, {List<Currency>? currencies}) async {
    var data = await db.getDocFuture(getCollectionPath(userId), id);
    Wallet wallet = Wallet.fromJson(data);
    if (currencies != null) {
      wallet.currency = currencies.firstWhere((c) => c.id == wallet.currencyId);
    }
    return wallet;
  }

  ValueStream<List<Wallet>> getWallets(String userId) {
    if (_wallets != null) return _wallets!;
    _wallets = CombineLatestStream.list([
      db.getAll(getCollectionPath(userId)).asyncMap((snapshot) => snapshot.toList()),
      currencyRx.getCurrencies(),
    ]).asyncMap((list) {
      var wallets = list[0] as List<Map<String, dynamic>>;
      var currencies = list[1] as List<Currency>;
      return wallets.map(
        (raw) {
          var wallet = Wallet.fromJson(raw);
          wallet.currency = currencies.firstWhere((c) => c.id == wallet.currencyId);
          return wallet;
        },
      ).toList();
    }).shareValue();
    return _wallets!;
  }

  Future<String> create(Wallet data, String userId) {
    return db.createDoc(getCollectionPath(userId), data.toJson());
  }

  Future update(Wallet data, String userId) {
    return db.updateDoc(getCollectionPath(userId), data.toJson(), data.id);
  }

  Future delete(String id, String userId) async {
    var transactionPath = TransactionRx.getCollectionPath(userId);
    var refWalletsFrom = db.getCollection(transactionPath).where('walletFromId', isEqualTo: id);
    var refWalletsTo = db.getCollection(transactionPath).where('walletToId', isEqualTo: id);

    await transactionRx.deleteAll(
      List.from(await db.getDocIdsOf(transactionPath, reference: refWalletsFrom)),
      userId,
    );

    await transactionRx.deleteAll(
      List.from(await db.getDocIdsOf(transactionPath, reference: refWalletsTo)),
      userId,
    );

    return db.deleteDoc(getCollectionPath(userId), id);
  }
}

WalletRx walletRx = WalletRx();
