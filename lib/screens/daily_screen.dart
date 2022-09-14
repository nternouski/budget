import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/classes.dart';
import '../common/period_stats.dart';
import '../common/preference.dart';
import '../components/empty_list.dart';
import '../model/user.dart';
import '../server/database/transaction_rx.dart';
import '../common/styles.dart';
import '../components/daily_item.dart';
import '../components/spend_graphic.dart';
import '../model/transaction.dart';

class DailyScreen extends StatefulWidget {
  const DailyScreen({Key? key}) : super(key: key);

  @override
  DailyScreenState createState() => DailyScreenState();
}

class DailyScreenState extends State<DailyScreen> {
  Preferences preferences = Preferences();
  bool fetchAll = false;

  DailyScreenState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    User? user = Provider.of<User>(context) as dynamic;
    if (user == null) return ScreenInit.getScreenInit(context);

    return Scaffold(
      appBar: AppBar(
        titleTextStyle: theme.textTheme.titleLarge,
        leading: getLadingButton(context),
        title: const Text('Daily Transaction'),
      ),
      body: Column(children: [
        ValueListenableBuilder<PeriodStats>(
          valueListenable: periods.selected,
          builder: (context, periodStats, child) => SpendGraphic(
            frameRange: periodStats.days,
            user: user,
            key: Key(Random().nextDouble().toString()),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [getBody(theme, user)],
            ),
            onRefresh: () async => setState(() {}),
          ),
        )
      ]),
    );
  }

  Widget getBody(ThemeData theme, User user) {
    return StreamBuilder<List<Transaction>>(
      stream: transactionRx.getTransactions(user.id, fetchAll: fetchAll),
      builder: (BuildContext context, snapshot) {
        List<Transaction> transactions = List.castFrom(snapshot.data ?? []);
        transactions.sort((a, b) => b.date.compareTo(a.date));
        if (transactions.isEmpty) {
          return const SliverToBoxAdapter(
            child: EmptyList(urlImage: 'assets/images/new-spend.png', text: 'What will be your first spend?'),
          );
        } else {
          String symbol = user.defaultCurrency.symbol;
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 80),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text('Currency $symbol')]),
                  ),
                  ...List.generate(
                    transactions.length,
                    (index) => DailyItem(transaction: transactions[index], key: Key(Random().nextDouble().toString())),
                  ),
                  if (transactions.length > 10 && !fetchAll)
                    TextButton(onPressed: () => setState(() => fetchAll = true), child: const Text('Get All')),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
