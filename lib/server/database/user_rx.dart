import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

import 'package:budget/common/error_handler.dart';
import 'package:budget/model/currency.dart';
import 'package:budget/model/transaction.dart';
import 'package:budget/model/user.dart';
import 'package:budget/model/wallet.dart';
import 'package:budget/server/database/currency_rx.dart';
import 'package:budget/server/database.dart';
import 'package:budget/server/database/transaction_rx.dart';
import 'package:budget/server/database/wallet_rx.dart';

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

  CurrencyRate? findRate(List<CurrencyRate> rates, String fromId, String toId) {
    return rates.firstWhereOrNull((r) =>
        (r.currencyFrom.id == fromId && r.currencyTo.id == toId) ||
        (r.currencyFrom.id == toId && r.currencyTo.id == fromId));
  }

  Future updateCurrency(User user, Currency newCurrency, List<CurrencyRate> rates) async {
    var cr = findRate(rates, user.defaultCurrency.id, newCurrency.id);
    if (cr == null) throw Exception('There are not currency rates to swap the default currency.');
    String walletPath = WalletRx.getCollectionPath(user.id);
    String transactionPath = TransactionRx.getCollectionPath(user.id);

    List<Wallet> wallets = await db.getDocsFuture(walletPath).then((data) => data.map((w) {
          Wallet wallet = Wallet.fromJson(w);
          if (wallet.currencyId != newCurrency.id && findRate(rates, wallet.currencyId, newCurrency.id) == null) {
            throw Exception('There are not currency rates to swap on wallets.');
          }
          return wallet;
        }).toList());

    for (var wallet in wallets) {
      double newWalletBalance = 0;
      var ref = db.getCollection(transactionPath).where('walletId', isEqualTo: wallet.id);
      List<Transaction> transactions = await db
          .getDocsFuture(transactionPath, ref: ref)
          .then((data) => data.map((t) => Transaction.fromJson(t, [])).toList());
      var currencyRate = findRate(rates, wallet.currencyId, newCurrency.id);
      for (var transaction in transactions) {
        if (currencyRate == null) {
          transaction.balanceFixed = transaction.balance;
        } else {
          transaction.balanceFixed = currencyRate.convert(transaction.balance, wallet.currencyId, newCurrency.id);
        }
        newWalletBalance += transaction.balanceFixed;
        await db.updateDoc(transactionPath, transaction.toJson(), transaction.id);
      }
      wallet.balanceFixed = newWalletBalance;
      await db.updateDoc(walletPath, wallet.toJson(), wallet.id);
    }

    user.initialAmount = cr.convert(user.initialAmount, user.defaultCurrency.id, newCurrency.id);
    user.defaultCurrency = newCurrency;
    return db.updateDoc(collectionPath, user.toJson(), user.id);
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
