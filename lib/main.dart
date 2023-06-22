// @dart=2.9
import 'dart:async';
import 'package:budget/common/device_info_notifier.dart';
import 'package:budget/common/playlist_notifier.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';

import './screens/email_verification_screen.dart';
import './model/expense_prediction.dart';
import './model/budget.dart';
import './model/category.dart';
import './model/currency.dart';
import './model/transaction.dart';
import './model/wallet.dart';
import './server/database/expense_prediction_rx.dart';
import './server/database/budget_rx.dart';
import './server/database/category_rx.dart';
import './server/database/currency_rate_rx.dart';
import './server/database/currency_rx.dart';
import './server/database/transaction_rx.dart';
import './server/database/wallet_rx.dart';
import './server/auth.dart';
import './common/preference.dart';
import './common/prediction_on_stats.dart';
import './common/classes.dart';
import './common/ad_helper.dart';
import './common/error_handler.dart';
import './common/theme.dart';
import './routes.dart';
import './model/user.dart';
import './server/user_service.dart';

final UserService userService = UserService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: '.env');
  final adsInitialization = MobileAds.instance.initialize();
  final adState = AdStateNotifier(initialization: adsInitialization);

  final preferences = Preferences();

  runZonedGuarded<Future<void>>(
    () async {
      Future.wait([preferences.getBool(PreferenceType.authLoginEnable)]).then((p) {
        return runApp(MyApp(
          adState: adState,
          // ignore: unnecessary_cast
          authLoginEnable: p[0] as bool ?? false,
        ));
      });
    },
    (dynamic error, StackTrace stackTrace) {
      HandlerError().setError(error.toString());
    },
  );
}

class MyApp extends StatelessWidget {
  final AdStateNotifier adState;
  final bool authLoginEnable;

  const MyApp({Key key, this.adState, this.authLoginEnable}) : super(key: key);

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
        StreamProvider<List<ExpensePrediction>>(
            create: (context) {
              return expensePredictionRx.getExpensePredictions(Provider.of<auth.User>(context, listen: false).uid);
            },
            initialData: const [],
            catchError: (context, error) {
              HandlerError().setError(error.toString());
              return [];
            }),
        ChangeNotifierProvider<EmailVerificationNotifier>(create: (context) => EmailVerificationNotifier()),
        ChangeNotifierProvider<ThemeProvider>(create: (context) => ThemeProvider()),
        ChangeNotifierProvider<LocalAuthNotifier>(create: (context) => LocalAuthNotifier(authLoginEnable)),
        ChangeNotifierProvider<DeviceInfoNotifier>(create: (context) => DeviceInfoNotifier()),
        ChangeNotifierProvider<AdStateNotifier>(create: (context) => adState),
        ChangeNotifierProvider<LanguageNotifier>(create: (context) => LanguageNotifier()),
        ChangeNotifierProvider<DailyItemBalanceNotifier>(create: (context) => DailyItemBalanceNotifier()),
        ChangeNotifierProvider<PredictionOnStatsNotifier>(create: (context) => PredictionOnStatsNotifier()),
        ChangeNotifierProvider<PlaylistNotifier>(create: (context) => PlaylistNotifier()),
      ],
      builder: (context, child) {
        LanguageNotifier langNotifier = Provider.of<LanguageNotifier>(context);

        Intl.systemLocale = langNotifier.localeShort;
        Intl.defaultLocale = langNotifier.localeShort;

        return I18n(
          key: langNotifier.i18nUniqueKey,
          initialLocale: langNotifier.locale,
          child: MaterialApp(
            title: 'Budget',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalWidgetsLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('es')],
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
