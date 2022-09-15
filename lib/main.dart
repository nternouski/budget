// @dart=2.9
import 'dart:async';
import 'package:budget/model/budget.dart';
import 'package:budget/model/category.dart';
import 'package:budget/model/currency.dart';
import 'package:budget/model/transaction.dart';
import 'package:budget/model/wallet.dart';
import 'package:budget/server/database/budget_rx.dart';
import 'package:budget/server/database/category_rx.dart';
import 'package:budget/server/database/currency_rate_rx.dart';
import 'package:budget/server/database/currency_rx.dart';
import 'package:budget/server/database/transaction_rx.dart';
import 'package:budget/server/database/wallet_rx.dart';
import 'package:budget/server/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import './common/error_handler.dart';
import './common/preference.dart';
import './common/theme.dart';
import './routes.dart';
import './model/user.dart';
import './server/user_service.dart';

final UserService userService = UserService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Preferences preferences = Preferences();

  runZonedGuarded<Future<void>>(
    () async {
      Future.wait([
        preferences.getBool(PreferenceType.darkTheme),
        preferences.getBool(PreferenceType.authLoginEnable),
      ]).then(
        (p) {
          final darkTheme = p[0];
          final authLoginEnable = p[1] ?? false;

          ThemeMode themeMode = darkTheme == null
              ? ThemeMode.system
              : darkTheme
                  ? ThemeMode.dark
                  : ThemeMode.light;

          return runApp(MyApp(themeMode: themeMode, authLoginEnable: authLoginEnable));
        },
      );
    },
    (dynamic error, StackTrace stackTrace) {
      HandlerError().setError(error.toString());
    },
  );
}

class MyApp extends StatelessWidget {
  final ThemeMode themeMode;
  final bool authLoginEnable;

  const MyApp({Key key, this.themeMode, this.authLoginEnable}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<auth.User>(create: (context) => userService.userAuth, initialData: null),
        StreamProvider<User>(create: (context) => userService.userRx, initialData: null),
        StreamProvider<List<Currency>>(create: (context) => currencyRx.getCurrencies(), initialData: const []),
        StreamProvider<List<CurrencyRate>>(
            create: (context) => currencyRateRx.getCurrencyRates(Provider.of<auth.User>(context, listen: false).uid),
            initialData: const [],
            catchError: (context, error) {
              HandlerError().setError(error.toString());
              return [];
            }),
        StreamProvider<List<Category>>(
            create: (context) => categoryRx.getCategories(Provider.of<auth.User>(context, listen: false).uid),
            initialData: const []),
        StreamProvider<List<Transaction>>(
            create: (context) => transactionRx.getTransactions(Provider.of<auth.User>(context, listen: false).uid),
            initialData: const [],
            catchError: (context, error) {
              HandlerError().setError(error.toString());
              return [];
            }),
        StreamProvider<List<Wallet>>(
            create: (context) => walletRx.getWallets(Provider.of<auth.User>(context, listen: false).uid),
            initialData: const []),
        StreamProvider<List<Budget>>(
            create: (context) => budgetRx.getBudgets(Provider.of<auth.User>(context, listen: false).uid),
            initialData: const [],
            catchError: (context, error) {
              HandlerError().setError(error.toString());
              return [];
            }),
        ChangeNotifierProvider<ThemeProvider>(create: (context) => ThemeProvider(themeMode)),
        ChangeNotifierProvider<LocalAuthProvider>(create: (context) => LocalAuthProvider(authLoginEnable)),
      ],
      builder: (context, child) {
        return MaterialApp(
          title: 'Budget',
          debugShowCheckedModeBanner: false,
          theme: ThemeProvider.light,
          darkTheme: ThemeProvider.dark,
          themeMode: Provider.of<ThemeProvider>(context).themeMode,
          home: const AuthWrapper(),
          routes: RouteApp.routes,
        );
      },
    );
  }
}
