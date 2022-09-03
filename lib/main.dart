// @dart=2.9
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import './common/error_handler.dart';
import './common/preference.dart';
import './common/theme.dart';
import './model/category.dart';
import './model/budget.dart';
import './model/transaction.dart';
import './model/wallet.dart';
import './routes.dart';
import './model/user.dart';
import './server/user_service.dart';
import './server/model_rx.dart';
import './server/graphql_config.dart';
import './model/currency.dart';
import './components/bottom_navigation_bar_widget.dart';
import './screens/onboarding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // We're using HiveStore for persistence, so we need to initialize Hive.
  await initHiveForFlutter();

  Preferences().getBool(PreferenceType.darkTheme).then(
        (darkTheme) => runApp(MyApp(
          themeMode: darkTheme == null
              ? ThemeMode.system
              : darkTheme
                  ? ThemeMode.dark
                  : ThemeMode.light,
        )),
      );
}

class MyApp extends StatelessWidget {
  final ThemeMode themeMode;
  final UserService userService = UserService();

  MyApp({Key key, this.themeMode}) : super(key: key) {
    currencyRx.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<Token>(create: (context) => userService.tokenRx, initialData: null),
        StreamProvider<List<Currency>>(create: (context) => currencyRx.fetchRx, initialData: const []),
        StreamProvider<List<CurrencyRate>>(create: (context) => currencyRateRx.fetchRx, initialData: const []),
        StreamProvider<User>(create: (context) => userService.userRx, initialData: null),
        StreamProvider<List<Category>>(create: (context) => categoryRx.fetchRx, initialData: const []),
        StreamProvider<List<Wallet>>(create: (context) => walletRx.fetchRx, initialData: const []),
        StreamProvider<List<Transaction>>(
          create: (context) {
            return transactionRx.fetchRx.asyncMap((transactions) {
              Currency defaultCurrency = Provider.of<User>(context, listen: false)?.defaultCurrency;
              List<Wallet> wallets = Provider.of<List<Wallet>>(context, listen: false);
              List<CurrencyRate> currencyRates = Provider.of<List<CurrencyRate>>(context, listen: false);
              return transactionRx.updateTransactions(transactions, wallets, currencyRates, defaultCurrency);
            });
          },
          initialData: null,
        ),
        StreamProvider<List<Budget>>(
          create: (context) => budgetRx.fetchRx.asyncMap(
            (budgets) => budgetRx.updateBudgets(budgets, Provider.of<List<Transaction>>(context, listen: false) ?? []),
          ),
          initialData: const [],
        ),
        ChangeNotifierProvider<ThemeProvider>(create: (context) => ThemeProvider(themeMode)),
      ],
      builder: (context, child) {
        return GraphQLProvider(
          client: graphQLConfig.clientValueNotifier,
          child: MaterialApp(
            title: 'Budget',
            debugShowCheckedModeBanner: false,
            theme: ThemeProvider.light,
            darkTheme: ThemeProvider.dark,
            themeMode: Provider.of<ThemeProvider>(context).themeMode,
            home: const AuthWrapper(),
            routes: RouteApp.routes,
          ),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Token token = Provider.of<Token>(context);
    final HandlerError handlerError = HandlerError();
    handlerError.notifier.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) => handlerError.showError(context));
    });
    return token != null && token.isLogged() ? const BottomNavigationBarWidget() : const OnBoarding();
  }
}
