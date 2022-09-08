import 'dart:math';
import 'package:budget/common/classes.dart';
import 'package:budget/common/period_stats.dart';
import 'package:budget/common/preference.dart';
import 'package:budget/common/theme.dart';
import 'package:budget/components/empty_list.dart';
import 'package:budget/model/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  DailyScreenState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<Transaction>? transactions = Provider.of<List<Transaction>>(context);
    User? user = Provider.of<User>(context);

    if (user == null) return ScreenInit.getScreenInit(context);

    return Scaffold(
      body: Column(children: [
        SizedBox(
          height: 310,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                titleTextStyle: theme.textTheme.titleLarge,
                pinned: true,
                leading: getLadingButton(context),
                title: const Text('Daily Transaction'),
              ),
              SliverToBoxAdapter(
                child: ValueListenableBuilder<PeriodStats>(
                  valueListenable: periods.selected,
                  builder: (context, periodStats, child) {
                    if (transactions != null) {
                      return SpendGraphic(
                        frameRange: periodStats.days,
                        transactions: transactions,
                        user: user,
                        key: Key(Random().nextDouble().toString()),
                      );
                    } else {
                      return Container(
                        alignment: Alignment.center,
                        width: 50,
                        height: 50,
                        child: Progress.getLoadingProgress(context: context),
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [getBody(theme, transactions, user)],
            ),
            onRefresh: () async => setState(() {}),
          ),
        )
      ]),
    );
  }

  Widget getBody(ThemeData theme, List<Transaction>? transactions, User user) {
    if (transactions != null) {
      transactions.sort((a, b) => b.date.compareTo(a.date));
      if (transactions.isEmpty) {
        return const SliverToBoxAdapter(
          child: EmptyList(urlImage: 'assets/images/new-spend.png', text: 'What will be your first spend?'),
        );
      } else {
        String symbol = user.defaultCurrency != null ? user.defaultCurrency!.symbol : '';
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 80, left: 20, right: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [Text('Currency $symbol')],
                ),
                ...List.generate(
                  transactions.length,
                  (index) => DailyItem(transaction: transactions[index], key: Key(Random().nextDouble().toString())),
                )
              ],
            ),
          ),
        );
      }
    } else {
      return SliverToBoxAdapter(
        child: Container(
          alignment: Alignment.center,
          width: 50,
          height: 50,
          child: Progress.getLoadingProgress(context: context),
        ),
      );
    }
  }
}
