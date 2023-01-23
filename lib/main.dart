// @dart=2.9
import 'dart:async';
import 'dart:ui' as ui;
import 'package:budget/common/classes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';

import '../screens/email_verification_screen.dart';
import '../common/ad_helper.dart';
import '../model/budget.dart';
import '../model/category.dart';
import '../model/currency.dart';
import '../model/transaction.dart';
import '../model/wallet.dart';
import '../server/database/budget_rx.dart';
import '../server/database/category_rx.dart';
import '../server/database/currency_rate_rx.dart';
import '../server/database/currency_rx.dart';
import '../server/database/transaction_rx.dart';
import '../server/database/wallet_rx.dart';
import '../server/auth.dart';
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
  await dotenv.load(fileName: '.env');
  final adsInitialization = MobileAds.instance.initialize();
  final adState = AdState(initialization: adsInitialization);

  Preferences preferences = Preferences();

  runZonedGuarded<Future<void>>(
    () async {
      Future.wait([
        preferences.getBool(PreferenceType.darkTheme),
        preferences.getBool(PreferenceType.authLoginEnable),
        preferences.getString(PreferenceType.languageCode),
      ]).then(
        (p) {
          final darkTheme = p[0] as bool;
          final authLoginEnable = p[1] as bool ?? false;
          final String languageCode = p[2] ?? '';

          ThemeMode themeMode = darkTheme == null
              ? ThemeMode.system
              : darkTheme
                  ? ThemeMode.dark
                  : ThemeMode.light;

          return runApp(MyApp(
              themeMode: themeMode, languageCode: languageCode, authLoginEnable: authLoginEnable, adState: adState));
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
  final String languageCode;
  final bool authLoginEnable;
  final AdState adState;

  const MyApp({Key key, this.themeMode, this.languageCode, this.authLoginEnable, this.adState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Locale locale = Locale(languageCode == '' ? Intl.shortLocale(ui.window.locale.languageCode) : languageCode);

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
        ChangeNotifierProvider<EmailVerificationNotifier>(create: (context) => EmailVerificationNotifier()),
        ChangeNotifierProvider<ThemeProvider>(create: (context) => ThemeProvider(themeMode)),
        ChangeNotifierProvider<LocalAuthProvider>(create: (context) => LocalAuthProvider(authLoginEnable)),
        ChangeNotifierProvider<AdState>(create: (context) => adState),
        ChangeNotifierProvider<LanguageNotifier>(create: (context) => LanguageNotifier(locale)),
      ],
      builder: (context, child) {
        Intl.systemLocale = Provider.of<LanguageNotifier>(context).localeShort;
        Intl.defaultLocale = Provider.of<LanguageNotifier>(context).localeShort;

        return I18n(
          initialLocale: locale,
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
