import 'package:budget/common/transform.dart';
import 'package:budget/model/budget.dart';
import 'package:budget/model/label.dart';
import 'package:stream_transform/stream_transform.dart';

import '../model/currency.dart';
import '../model/wallet.dart';
import '../model/category.dart';
import '../model/transaction.dart';
import './database.dart';

class TransactionRx extends Database<Transaction> {
  static final _queries = TransactionQueries();

  TransactionRx() : super(_queries, "transactions", Transaction.fromJson);

  Future<double> getBalanceAt(DateTime until) async {
    printMsg('GET');
    final value = await super.request(TypeRequest.query, _queries.getBalanceAt, {'until': until.toString()});
    if (value != null) {
      String balance = value['transactions_aggregate']['aggregate']['sum']['balance'] ?? '\$0.0';
      return Convert.currencyToDouble(balance);
    } else {
      return 0;
    }
  }

  _updateLabels(String id, List<Label> toUpdate) async {
    await request(TypeRequest.mutation, _queries.deleteLabels, {'transactionId': id});
    List<Label> labels = [];
    for (var label in toUpdate) {
      final value =
          await request(TypeRequest.mutation, _queries.insertLabels, {'transactionId': id, 'labelId': label.id});
      if (value != null && value['action']['returning'] != null) {
        labels.add(Label.fromJson(value['action']['returning'][0]['label']));
      }
    }
    super.behavior.add(behavior.value.map((t) {
          if (t.id == id) {
            t.labels = labels;
            return t;
          } else {
            return t;
          }
        }).toList());
  }

  @override
  create(Transaction data) async {
    Transaction? t = await super.create(data);
    if (t != null) _updateLabels(t.id, data.labels);
    return t;
  }

  @override
  update(Transaction data) async {
    await super.update(data);
    _updateLabels(data.id, data.labels);
  }

  @override
  delete(String id) async {
    await request(TypeRequest.mutation, _queries.deleteLabels, {'transactionId': id});
    super.delete(id);
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
  static final _queries = BudgetQueries();

  BudgetRx() : super(BudgetQueries(), "budgets", Budget.fromJson);

  _updateCategories(String id, List<Category> toUpdate) async {
    await request(TypeRequest.mutation, _queries.deleteCategories, {'budgetId': id});
    List<Category> categories = [];
    for (var category in toUpdate) {
      final value =
          await request(TypeRequest.mutation, _queries.insertCategories, {'budgetId': id, 'categoryId': category.id});
      if (value != null && value['action']['returning'] != null) {
        categories.add(Category.fromJson(value['action']['returning'][0]['category']));
      }
    }
    super.behavior.add(behavior.value.map((b) {
          if (b.id == id) {
            b.categories = categories;
            return b;
          } else {
            return b;
          }
        }).toList());
  }

  @override
  create(Budget data) async {
    Budget? b = await super.create(data);
    if (b != null) _updateCategories(b.id, data.categories);
    return b;
  }

  @override
  update(Budget data) async {
    await super.update(data);
    _updateCategories(data.id, data.categories);
  }

  @override
  delete(String id) async {
    await request(TypeRequest.mutation, _queries.deleteCategories, {'budgetId': id});
    super.delete(id);
  }
}

var categoryRx = Database(CategoryQueries(), "categories", Category.fromJson);
var walletRx = WalletRx();
var budgetRx = BudgetRx();
var currencyRx = Database(CurrencyQueries(), "currencies", Currency.fromJson);
var transactionRx = TransactionRx();
var labelRx = Database(LabelQueries(), "labels", Label.fromJson);

String userId = '3c940882-4628-4f71-9109-ff9439ee87fa';
