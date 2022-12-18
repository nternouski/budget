import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';

import '../../model/currency.dart';
import '../../model/wallet.dart';
import '../../server/database/wallet_rx.dart';
import '../../model/category.dart';
import '../../model/label.dart';
import '../../model/transaction.dart';
import '../../server/database/category_rx.dart';
import '../../server/database/label_rx.dart';
import '../../server/database.dart';
import '../../server/database/user_rx.dart';

class TransactionRx {
  @protected
  static String collectionPath = 'transactions';
  static String getCollectionPath(String userId) => '${UserRx.docPath(userId)}/$collectionPath';
  final db = Database();

  final windowFetchTransactions = const Duration(days: 30 * 3);
  ValueStream<List<Transaction>>? _transactions;

  List<Transaction> _updateTransactions(
    List<Map<String, dynamic>> listRaw,
    List<Category> categories,
    List<Label> labels,
    List<Wallet> wallets,
  ) {
    return listRaw.map((raw) {
      Transaction t = Transaction.fromJson(raw, labels);
      t.category = categories.firstWhere((c) => c.id == t.categoryId);
      return t;
    }).toList();
  }

  ValueStream<List<Transaction>> getTransactions(String userId, {bool fetchAll = false}) {
    var path = getCollectionPath(userId);
    var ref = db.getCollection(path).where('date', isGreaterThan: DateTime.now().subtract(windowFetchTransactions));
    if (fetchAll) {
      ref = db.getCollection(path);
      _transactions = null;
    }
    if (_transactions != null) return _transactions!;

    _transactions = CombineLatestStream.list<List<dynamic>>([
      db.getAll(path, reference: ref).asyncMap((snapshot) => snapshot.toList()),
      labelRx.getLabels(userId),
      categoryRx.getCategories(userId),
      walletRx.getWallets(userId),
    ]).asyncMap((list) {
      var listRaw = list[0] as List<Map<String, dynamic>>;
      var labels = list[1] as List<Label>;
      var categories = list[2] as List<Category>;
      var wallets = list[3] as List<Wallet>;
      return _updateTransactions(listRaw, categories, labels, wallets);
    }).shareValue();
    return _transactions!;
  }

  Future<String> create(
    Transaction data,
    String userId,
    Wallet walletFrom,
    List<CurrencyRate> currencyRates,
    Wallet? walletTo,
  ) async {
    walletFrom.updateBalance(data);
    await db.updateDoc(WalletRx.getCollectionPath(userId), walletFrom.toJson(), data.walletFromId);
    if (data.type == TransactionType.transfer && walletTo != null) {
      CurrencyRate cr = currencyRates.findCurrencyRate(walletFrom.currency!, walletTo.currency!);
      double balanceConverted = cr.convert(data.balance, walletFrom.currencyId, walletTo.currencyId);
      data.balanceConverted = balanceConverted;
      walletTo.updateBalance(data, balanceConverted: balanceConverted);
      await db.updateDoc(WalletRx.getCollectionPath(userId), walletTo.toJson(), data.walletToId);
    }
    return db.createDoc(getCollectionPath(userId), data.toJson());
  }

  Future update(
    Transaction newTrans,
    String userId,
    Wallet walletFrom,
    List<CurrencyRate> currencyRates,
    Wallet? walletTo,
  ) async {
    Transaction oldTransaction =
        Transaction.fromJson(await db.getDocFuture(getCollectionPath(userId), newTrans.id), []);
    newTrans.updateBalance();

    await _updateWallets(oldTransaction, newTrans, userId, walletFrom, currencyRates, walletTo);

    return db.updateDoc(getCollectionPath(userId), newTrans.toJson(), newTrans.id);
  }

  Future _updateWallets(
    Transaction oldTransaction,
    Transaction newTrans,
    String userId,
    Wallet walletFrom,
    List<CurrencyRate> currencyRates,
    Wallet? walletTo,
  ) async {
    // Update wallet related to "Wallet From"
    if (oldTransaction.walletFromId != newTrans.walletFromId) {
      var oldWallet = Wallet.fromJson(
        await db.getDocFuture(WalletRx.getCollectionPath(userId), oldTransaction.walletFromId),
      );
      oldWallet.updateBalance(oldTransaction, fromOld: true);
      await db.updateDoc(WalletRx.getCollectionPath(userId), oldWallet.toJson(), oldTransaction.walletFromId);
      walletFrom.updateBalance(newTrans);
      await db.updateDoc(WalletRx.getCollectionPath(userId), walletFrom.toJson(), walletFrom.id);
    } else {
      // Reset previous value of the transaction.
      walletFrom.updateBalance(oldTransaction, fromOld: true);
      walletFrom.updateBalance(newTrans);
      await db.updateDoc(WalletRx.getCollectionPath(userId), walletFrom.toJson(), walletFrom.id);
    }

    // Update wallet related  to transaction type transfer for "Wallet To"
    if (newTrans.type == TransactionType.transfer &&
        walletTo != null &&
        oldTransaction.walletToId != newTrans.walletToId) {
      var oldWallet = Wallet.fromJson(await db.getDocFuture(getCollectionPath(userId), oldTransaction.walletToId));
      oldWallet.updateBalance(oldTransaction, fromOld: true);
      await db.updateDoc(WalletRx.getCollectionPath(userId), oldWallet.toJson(), oldTransaction.walletToId);
      walletTo.updateBalance(newTrans);
      await db.updateDoc(WalletRx.getCollectionPath(userId), walletTo.toJson(), walletTo.id);
    } else if (newTrans.type == TransactionType.transfer && walletTo != null) {
      // Reset previous value of the transaction.
      walletTo.updateBalance(oldTransaction, fromOld: true);
      walletTo.updateBalance(newTrans);
      await db.updateDoc(WalletRx.getCollectionPath(userId), walletTo.toJson(), walletTo.id);
    }
  }

  Future delete(
    Transaction transaction,
    String userId,
    List<CurrencyRate> currencyRates,
    List<Currency> currencies,
  ) async {
    // Reset previous value of the transaction.
    Wallet walletFrom = await walletRx.getDocFuture(transaction.walletFromId, userId, currencies: currencies);
    walletFrom.updateBalance(transaction, fromOld: true);
    await db.updateDoc(WalletRx.getCollectionPath(userId), walletFrom.toJson(), transaction.walletFromId);
    if (transaction.type == TransactionType.transfer) {
      // Reset previous value of the transaction.
      Wallet walletTo = await walletRx.getDocFuture(transaction.walletToId, userId, currencies: currencies);
      CurrencyRate cr = currencyRates.findCurrencyRate(walletFrom.currency!, walletTo.currency!);
      double balanceConverted = cr.convert(transaction.balance, walletFrom.currencyId, walletTo.currencyId);
      walletTo.updateBalance(transaction, fromOld: true, balanceConverted: balanceConverted);
      await db.updateDoc(WalletRx.getCollectionPath(userId), walletTo.toJson(), transaction.walletToId);
    }
    return db.deleteDoc(getCollectionPath(userId), transaction.id);
  }

  Future deleteAll(List<String> transactionIds, String userId) async {
    for (var id in transactionIds) {
      await db.deleteDoc(getCollectionPath(userId), id);
    }
  }
}

TransactionRx transactionRx = TransactionRx();
