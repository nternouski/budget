import 'dart:developer';

import 'package:budget/common/classes.dart';
import 'package:budget/common/transform.dart';
import 'package:budget/model/budget.dart';
import 'package:stream_transform/stream_transform.dart';

import '../model/currency.dart';
import '../model/wallet.dart';
import '../model/category.dart';
import '../model/transaction.dart';
import './database.dart';

class TransactionRx extends Database<Transaction> {
  static final _queries = TransactionQueries();

  TransactionRx() : super(_queries, "transactions", Transaction.fromJson);

  Future<double> getBalanceAt() async {
    printMsg('GET');
    final value = await super.request(TypeRequest.query, _queries.getBalanceAt, {});
    if (value != null) {
      double balance = Convert.currencyToDouble(value['transactions_aggregate']['aggregate']['sum']['balance']);
      return balance;
    } else {
      return 0;
    }
  }
}

class WalletRx extends Database<Wallet> {
  @override
  late Stream<List<Wallet>> fetchRx;

  WalletRx() : super(WalletQueries(), "wallets", Wallet.fromJson) {
    fetchRx = super.fetchRx.combineLatest<List<Currency>, List<Wallet>>(
          currencyRx.fetchRx,
          (wallets, currencies) => wallets.map((w) {
            w.currency = currencies.firstWhere((c) => c.id == w.currencyId);
            return w;
          }).toList(),
        );
  }
}

class BudgetRx extends Database<Budget> {
  @override
  late Stream<List<Budget>> fetchRx;

  BudgetRx() : super(BudgetQueries(), "budgets", Budget.fromJson) {
    fetchRx = super.fetchRx.combineLatest<List<Currency>, List<Budget>>(
          currencyRx.fetchRx,
          (budgets, currencies) => budgets.map((w) {
            w.currency = currencies.firstWhere((c) => c.id == w.currencyId);
            return w;
          }).toList(),
        );
  }
}

var categoryRx = Database(CategoryQueries(), "categories", Category.fromJson);
var walletRx = WalletRx();
var budgetRx = BudgetRx();
var currencyRx = Database(CurrencyQueries(), "currencies", Currency.fromJson);
var transactionRx = TransactionRx();

String userId = '3c940882-4628-4f71-9109-ff9439ee87fa';
