import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

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
      t.wallet = wallets.firstWhere((w) => w.id == t.walletId);
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

  Future<String> create(Transaction data, String userId, Wallet wallet) async {
    wallet.balance += data.balance;
    wallet.balanceFixed += data.balanceFixed;
    await db.updateDoc(WalletRx.getCollectionPath(userId), wallet.toJson(), data.walletId);
    return db.createDoc(getCollectionPath(userId), data.toJson());
  }

  Future update(Transaction data, String userId, Wallet wallet) async {
    Transaction old = Transaction.fromJson(await db.getDocFuture(getCollectionPath(userId), data.id), []);

    if (old.walletId != data.walletId) {
      var oldWallet = Wallet.fromJson(await db.getDocFuture(getCollectionPath(userId), old.walletId));
      oldWallet.balance += -old.balance;
      oldWallet.balanceFixed += -old.balanceFixed;
      await db.updateDoc(WalletRx.getCollectionPath(userId), oldWallet.toJson(), old.walletId);
      wallet.balance += data.balance;
      wallet.balanceFixed += data.balanceFixed;
      await db.updateDoc(WalletRx.getCollectionPath(userId), wallet.toJson(), data.walletId);
    } else {
      double variation = -old.balance + data.balance;
      double variationFixed = -old.balanceFixed + data.balanceFixed;
      if (variation > 0 || variationFixed > 0) {
        wallet.balance = variation; // Reset previous value of the transaction.
        wallet.balanceFixed = variationFixed; // Reset previous value of the transaction.
        await db.updateDoc(WalletRx.getCollectionPath(userId), wallet.toJson(), data.walletId);
      }
    }
    return db.updateDoc(getCollectionPath(userId), data.toJson(), data.id);
  }

  Future delete(Transaction transaction, String userId) async {
    Wallet wallet = await walletRx.getDocFuture(transaction.walletId, userId);
    // Reset previous value of the transaction.
    wallet.balance += -transaction.balance;
    wallet.balanceFixed += -transaction.balanceFixed;
    await db.updateDoc(WalletRx.getCollectionPath(userId), wallet.toJson(), transaction.walletId);
    return db.deleteDoc(getCollectionPath(userId), transaction.id);
  }

  Future deleteAll(List<String> transactionIds, String userId) async {
    for (var id in transactionIds) {
      await db.deleteDoc(getCollectionPath(userId), id);
    }
  }
}

TransactionRx transactionRx = TransactionRx();
