// @dart=2.9
import 'package:budget/common/preference.dart';
import 'package:budget/common/theme.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

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
        StreamProvider<User>(create: (context) => userService.userRx, initialData: null),
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
    return token != null && token.isLogged() ? const BottomNavigationBarWidget() : const OnBoarding();
  }
}
