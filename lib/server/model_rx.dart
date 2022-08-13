import 'package:rxdart/rxdart.dart';

import '../common/convert.dart';
import '../model/budget.dart';
import '../model/label.dart';
import '../model/user.dart';
import '../model/currency.dart';
import '../model/wallet.dart';
import '../model/category.dart';
import '../model/transaction.dart';
import './database.dart';

class TransactionRx extends Database<Transaction> {
  static final _queries = TransactionQueries();

  TransactionRx() : super(_queries, 'transactions', Transaction.fromJson);

  Future<double> getBalanceAt(DateTime until) async {
    printMsg('GET - BALANCE');
    final value = await super
        .request(type: TypeRequest.query, query: _queries.getBalanceAt, variable: {'until': until.toString()});
    if (value != null) {
      String balance = value['transactions_aggregate']['aggregate']['sum']['balance'] ?? '\$0.0';
      return Convert.currencyToDouble(balance, value);
    } else {
      return 0;
    }
  }

  _updateLabels(String id, List<Label> toUpdate) async {
    await request(type: TypeRequest.mutation, query: _queries.deleteLabels, variable: {'transactionId': id});
    List<Label> labels = [];
    for (var label in toUpdate) {
      final value = await request(
          type: TypeRequest.mutation,
          query: _queries.insertLabels,
          variable: {'transactionId': id, 'labelId': label.id});
      if (value != null && value['action']['returning'] != null) {
        labels.add(Label.fromJson(value['action']['returning'][0]['label']));
      }
    }
    var data = behavior.hasValue ? behavior.value : List<Transaction>.from([]);
    super.behavior.add(data.map((t) {
          if (t.id == id) t.labels = labels;
          return t;
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
    await request(type: TypeRequest.mutation, query: _queries.deleteLabels, variable: {'transactionId': id});
    super.delete(id);
  }
}

class BudgetRx extends Database<Budget> {
  static final _queries = BudgetQueries();

  BudgetRx() : super(_queries, 'budgets', Budget.fromJson);

  _updateCategories(String id, List<Category> toUpdate) async {
    await request(type: TypeRequest.mutation, query: _queries.deleteCategories, variable: {'budgetId': id});
    List<Category> categories = [];
    for (var category in toUpdate) {
      final value = await request(
          type: TypeRequest.mutation,
          query: _queries.insertCategories,
          variable: {'budgetId': id, 'categoryId': category.id});
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
    await request(type: TypeRequest.mutation, query: _queries.deleteCategories, variable: {'budgetId': id});
    super.delete(id);
  }
}

class UserRx extends Database<User> {
  static final _queries = UserQueries();

  final user$ = BehaviorSubject<User>();
  Stream<User> get userRx => user$.stream;

  UserRx() : super(_queries, 'users', User.fromJson);

  Future<void> getCurrentUser(Token token, bool singUp, Currency? defaultCurrency) async {
    if (singUp) {
      var user = User(
        id: token.userId,
        createdAt: DateTime.now(),
        name: token.name,
        email: token.email,
        defaultCurrencyId: defaultCurrency?.id ?? '',
        defaultCurrency: defaultCurrency,
      );
      printMsg('CREATE USER');
      final value = await request(type: TypeRequest.mutation, query: _queries.create, variable: user.toJson());
      if (value != null && value['action']['returning'] != null) await updateData(user);
    } else {
      printMsg('GET USER BY ID');
      final value = await request(type: TypeRequest.query, query: _queries.getAll, variable: {}, throwError: true);
      if (value != null && value[collectionName] != null) {
        var users = List<User>.from(value[collectionName].map((t) => constructor(t)).toList());
        if (users.isNotEmpty) {
          await updateData(users[0]);
        } else {
          throw Exception('User not created');
        }
      }
    }
  }

  Future<void> updateData(User user) async {
    user$.add(user);
    transactionRx.getAll();
    labelRx.getAll();
  }

  Future<User?> getUser(String id) async {
    printMsg('GET USER BY ID: $id');
    final value = await request(type: TypeRequest.query, query: _queries.getUser, variable: {'id': id});
    if (value != null && value[collectionName] != null) {
      var users = List<User>.from(value[collectionName].map((t) => constructor(t)).toList());
      if (users.isNotEmpty) return users.length == 1 ? users[0] : throw 'More than 1 user';
    }
    return null;
  }

  @override
  update(User data) async {
    super.update(data);
    user$.add(data);
  }
}

var categoryRx = Database(CategoryQueries(), 'categories', Category.fromJson);
var walletRx = Database(WalletQueries(), 'wallets', Wallet.fromJson);
var budgetRx = BudgetRx();
var currencyRx = Database(CurrencyQueries(), 'currencies', Currency.fromJson);
var transactionRx = TransactionRx();
var labelRx = Database(LabelQueries(), 'labels', Label.fromJson);
