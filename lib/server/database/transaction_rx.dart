import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../../common/error_handler.dart';
import '../../model/category.dart';
import '../../model/currency.dart';
import '../../model/label.dart';
import '../../model/transaction.dart';
import '../../model/wallet.dart';
import '../../server/database/category_rx.dart';
import '../../server/database/currency_rate_rx.dart';
import '../../server/database/label_rx.dart';
import '../../server/database/wallet_rx.dart';
import '../../server/database.dart';
import '../../server/database/user_rx.dart';

class TransactionRx {
  @protected
  static String collectionPath = 'transactions';
  final db = Database();

  List<Transaction> _updateTransactions(
    List<Map<String, dynamic>> listRaw,
    List<Category> categories,
    List<Wallet> wallets,
    List<Label> labels,
    List<CurrencyRate> currencyRates,
    Currency? defaultCurrency,
  ) {
    return listRaw.map((raw) {
      Transaction t = Transaction.fromJson(raw, labels);
      t.category = categories.firstWhere((c) => c.id == t.categoryId);
      Wallet wallet = wallets.firstWhere((w) => w.id == t.walletId);
      var defaultCurrencyId = defaultCurrency?.id ?? '';
      if (defaultCurrencyId != '' && defaultCurrencyId != wallet.currencyId) {
        int rateIndex = currencyRates.lastIndexWhere((r) =>
            ((defaultCurrencyId == r.currencyFrom.id && wallet.currencyId == r.currencyTo.id) ||
                (defaultCurrencyId == r.currencyTo.id && wallet.currencyId == r.currencyFrom.id)));
        if (rateIndex != -1) {
          CurrencyRate cr = currencyRates.elementAt(rateIndex);
          bool fromTo = defaultCurrencyId == cr.currencyFrom.id && wallet.currencyId == cr.currencyTo.id;
          t.balanceFixed = double.parse(
            (fromTo ? t.balance * cr.rate : t.balance / cr.rate).toStringAsFixed(2),
          );
        } else {
          String defaultSymbol = defaultCurrency?.symbol ?? '';
          String tSymbol = wallet.currency?.symbol ?? '';
          HandlerError().setError('No currency rate por $defaultSymbol-$tSymbol or $tSymbol-$defaultSymbol');
        }
      }
      return t;
    }).toList();
  }

  ValueStream<List<Transaction>> getTransactions(String userId, Currency? defaultCurrency) {
    String path = '${UserRx.docPath(userId)}/$collectionPath';
    return CombineLatestStream.list<List<dynamic>>([
      db.getAll(path).asyncMap((snapshot) => snapshot.toList()),
      walletRx.getWallets(userId),
      labelRx.getLabels(userId),
      currencyRateRx.getCurrencyRates(userId),
      categoryRx.getCategories(userId),
    ]).asyncMap((list) {
      var listRaw = list[0] as List<Map<String, dynamic>>;
      var wallets = list[1] as List<Wallet>;
      var labels = list[2] as List<Label>;
      var currencyRates = list[3] as List<CurrencyRate>;
      var categories = list[4] as List<Category>;
      return _updateTransactions(listRaw, categories, wallets, labels, currencyRates, defaultCurrency);
    }).shareValue();
  }

  Future<String> create(Transaction data, String userId) {
    return db.createDoc('${UserRx.docPath(userId)}/$collectionPath', data.toJson());
  }

  Future update(Transaction data, String userId) {
    return db.updateDoc('${UserRx.docPath(userId)}/$collectionPath', data.toJson(), data.id);
  }

  Future delete(String id, String userId) {
    return db.deleteDoc('${UserRx.docPath(userId)}/$collectionPath', id);
  }
}

TransactionRx transactionRx = TransactionRx();
