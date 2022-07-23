// @dart=2.9

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import './components/bottom_navigation_bar_widget.dart';
import './common/color_constants.dart';
import './server/model_rx.dart';
import './server/graphql_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // We're using HiveStore for persistence, so we need to initialize Hive.
  await initHiveForFlutter();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    currencyRx.getAll();

    return GraphQLProvider(
      client: graphQLConfig.clientValueNotifier,
      child: MaterialApp(
        title: 'Budget',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: primary,
        ),
        home: BottomNavigationBarWidget(),
      ),
    );
  }

// FIXME: VEr de correr esto
  // @override
  // void dispose() {
  //   graphQLConfig.clientValueNotifier.dispose();
  // }
}
