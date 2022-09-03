import 'package:budget/common/error_handler.dart';
import 'package:rxdart/rxdart.dart';

import '../model/integration.dart';
import '../server/user_service.dart';
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

  List<Transaction> updateTransactions(
    List<Transaction> transactions,
    List<Wallet> wallets,
    List<CurrencyRate> currencyRates,
    Currency? defaultCurrency,
  ) {
    return transactions.map((t) {
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

  _updateLabels(String id, List<Label> toUpdate) async {
    await request(type: TypeRequest.mutation, query: _queries.deleteLabels, variable: {'transactionId': id});
    List<Label> labels = [];
    for (var label in toUpdate) {
      final value = await request(
        type: TypeRequest.mutation,
        query: _queries.insertLabels,
        variable: {'transactionId': id, 'labelId': label.id},
      );
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
    Transaction? t = await super.update(data);
    _updateLabels(data.id, data.labels);
    return t;
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

  List<Budget> updateBudgets(List<Budget> budgets, List<Transaction> transactions) {
    return budgets.map((budget) {
      budget.balance = transactions.fold(0.0, (prev, transaction) {
        if (budget.categories.where((c) => c.id == transaction.categoryId).isNotEmpty) {
          return prev + transaction.balance;
        } else {
          return prev;
        }
      });

      return budget;
    }).toList();
  }

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
    Budget? b = await super.update(data);
    _updateCategories(data.id, data.categories);
    return b;
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
        integrations: [],
        defaultCurrencyId: defaultCurrency?.id ?? '',
        defaultCurrency: defaultCurrency,
      );
      printMsg('CREATE USER');
      final value = await request(type: TypeRequest.mutation, query: _queries.create, variable: user.toJson());
      if (value != null && value['action']['returning'] != null) await updateData(user);
    } else {
      printMsg('GET USER BY ID');
      refreshUserData(token.userId);
    }
  }

  Future<void> updateData(User user) async {
    user$.add(user);
    currencyRateRx.getAll();
    walletRx.getAll();
    labelRx.getAll();
    categoryRx.getAll();
    transactionRx.getAll();
    budgetRx.getAll();
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

  Future<void> refreshUserData(String userId) async {
    User? user = await getUser(userId);
    if (user != null) {
      await updateData(user);
    } else {
      throw Exception('User not created');
    }
  }

  @override
  update(User data) async {
    User? u = await super.update(data);
    if (u != null) user$.add(data);
    return u;
  }
}

class IntegrationRx extends Database<Integration> {
  static final _queries = IntegrationQueries();

  IntegrationRx() : super(_queries, 'integrations', Integration.fromJson);

  @override
  create(Integration data) async {
    Integration? i = await super.create(data);
    if (i != null) {
      UserService().refreshUserData(data.userId);
    }
    return i;
  }

  @override
  update(Integration data) async {
    return await super.update(data);
  }
}

var categoryRx = Database(CategoryQueries(), 'categories', Category.fromJson);
var walletRx = Database(WalletQueries(), 'wallets', Wallet.fromJson);
var budgetRx = BudgetRx();
var integrationRx = IntegrationRx();
var currencyRx = Database(CurrencyQueries(), 'currencies', Currency.fromJson);
var currencyRateRx = Database(CurrencyRateQueries(), 'currency_rates', CurrencyRate.fromJson);
var transactionRx = TransactionRx();
var labelRx = Database(LabelQueries(), 'labels', Label.fromJson);
