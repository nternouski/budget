import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

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

  Future updateCurrency(User user, Currency newCurrency, List<CurrencyRate> rates) async {
    var cr = rates.findCurrencyRate(user.defaultCurrency, newCurrency,
        errorMessage: 'There are not currency rates to swap the default currency.');
    String walletCollectionPath = WalletRx.getCollectionPath(user.id);
    String transactionCollectionPath = TransactionRx.getCollectionPath(user.id);

    List<Wallet> wallets = await db.getDocsFuture(walletCollectionPath).then((data) => data.map((w) {
          Wallet wallet = Wallet.fromJson(w);
          if (wallet.currencyId != newCurrency.id) {
            try {
              rates.findCurrencyRate(wallet.currency!, newCurrency);
            } catch (e) {
              throw Exception('There are not currency rates to swap on wallets.');
            }
          }
          return wallet;
        }).toList());

    for (var wallet in wallets) {
      double newWalletBalance = 0;

      var refFrom = db.getCollection(transactionCollectionPath).where('walletFromId', isEqualTo: wallet.id);
      List<Transaction> transactionsFrom = await db
          .getDocsFuture(transactionCollectionPath, ref: refFrom)
          .then((data) => data.map((t) => Transaction.fromJson(t, [])).toList());
      var refTo = db.getCollection(transactionCollectionPath).where('walletToId', isEqualTo: wallet.id);
      List<Transaction> transactionsTo = await db
          .getDocsFuture(transactionCollectionPath, ref: refTo)
          .then((data) => data.map((t) => Transaction.fromJson(t, [])).toList());

      List<Transaction> transactions = [...transactionsFrom, ...transactionsTo].toList();
      var currencyRate = rates.findCurrencyRate(wallet.currency!, newCurrency);
      for (var transaction in transactions) {
        transaction.balanceFixed = currencyRate.convert(transaction.balance, wallet.currencyId, newCurrency.id);
        newWalletBalance += transaction.balanceFixed;
        await db.updateDoc(transactionCollectionPath, transaction.toJson(), transaction.id);
      }
      wallet.balanceFixed = newWalletBalance;
      await db.updateDoc(walletCollectionPath, wallet.toJson(), wallet.id);
    }

    user.initialAmount = cr.convert(user.initialAmount, user.defaultCurrency.id, newCurrency.id);
    user.defaultCurrency = newCurrency;
    return db.updateDoc(collectionPath, user.toJson(), user.id);
  }

  Future calcWallets(User user, List<Wallet> wallets, List<CurrencyRate> currencyRates) async {
    List<Transaction> transactions = await db
        .getDocsFuture(TransactionRx.getCollectionPath(user.id))
        .then((data) => data.map((t) => Transaction.fromJson(t, [])).toList());

    for (var wallet in wallets) {
      wallet.balance = 0;
      wallet.balanceFixed = 0;
      for (var t in transactions) {
        debugPrint('${wallet.id == t.walletFromId}');
        if (wallet.id == t.walletFromId) {
          wallet.updateBalance(t);
        } else if (wallet.id == t.walletToId) {
          Wallet walletFrom = wallets.firstWhere((w) => w.id == t.walletFromId);
          Wallet walletTo = wallets.firstWhere((w) => w.id == t.walletToId);
          CurrencyRate cr = currencyRates.findCurrencyRate(walletFrom.currency!, walletTo.currency!);
          double balanceConverted = cr.convert(t.balance, walletFrom.currencyId, walletTo.currencyId);
          wallet.updateBalance(t, balanceConverted: balanceConverted);
        }
      }
      await db.updateDoc(WalletRx.getCollectionPath(user.id), wallet.toJson(), wallet.id);
    }
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
