import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../i18n/index.dart';
import '../common/classes.dart';
import '../common/period_stats.dart';
import '../common/preference.dart';
import '../components/empty_list.dart';
import '../model/wallet.dart';
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
    final gradientPrimary = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0, 0.15],
        colors: [
          theme.colorScheme.primary.withOpacity(OPACITY),
          theme.colorScheme.primary.withOpacity(0.0),
        ],
      ),
    );
    final gradientDisappear = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0, 0.15],
        colors: [
          theme.scaffoldBackgroundColor,
          theme.scaffoldBackgroundColor.withOpacity(0.0),
        ],
      ),
    );

    User? user = Provider.of<User>(context) as dynamic;
    List<Wallet> wallets = List.from(Provider.of<List<Wallet>>(context));
    if (user == null) return ScreenInit.getScreenInit(context);

    return Scaffold(
      appBar: AppBar(
        titleTextStyle: theme.textTheme.titleLarge,
        leading: getLadingButton(context),
        title: Text('Daily Transaction'.i18n),
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
          child: Container(
            foregroundDecoration: gradientPrimary,
            child: Container(
              padding: const EdgeInsets.only(top: 20),
              foregroundDecoration: gradientDisappear,
              child: RefreshIndicator(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [getBody(theme, user, wallets)],
                ),
                onRefresh: () async => setState(() {}),
              ),
            ),
          ),
        )
      ]),
    );
  }

  Widget getBody(ThemeData theme, User user, List<Wallet> wallets) {
    return StreamBuilder<List<Transaction>>(
      stream: transactionRx.getTransactions(user.id, fetchAll: fetchAll),
      builder: (BuildContext context, snapshot) {
        List<Transaction> transactions = List.castFrom(snapshot.data ?? []);
        transactions.sort((a, b) => b.date.compareTo(a.date));
        if (transactions.isEmpty) {
          return SliverToBoxAdapter(
            child: EmptyList(urlImage: 'assets/images/new-spend.png', text: 'What will be your first spend?'.i18n),
          );
        } else {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 130, left: 5, right: 5),
              child: Column(
                children: [
                  ...List.generate(
                    transactions.length,
                    (index) => DailyItem(transaction: transactions[index], key: Key(Random().nextDouble().toString())),
                  ),
                  if (!fetchAll)
                    TextButton(onPressed: () => setState(() => fetchAll = true), child: Text('See All'.i18n)),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
