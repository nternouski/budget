import 'dart:math';
import 'package:budget/common/theme.dart';
import 'package:budget/components/empty_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../server/model_rx.dart';
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
  DailyScreenState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<Transaction>? transactions = Provider.of<List<Transaction>>(context);

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
                child: transactions != null
                    ? SpendGraphic(transactions: transactions, key: Key(Random().nextDouble().toString()))
                    : Container(
                        alignment: Alignment.center,
                        width: 50,
                        height: 50,
                        child: Progress.getLoadingProgress(context: context),
                      ),
              )
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [getBody(theme, transactions)],
            ),
            onRefresh: () => transactionRx.getAll(),
          ),
        )
      ]),
    );
  }

  Widget getBody(ThemeData theme, List<Transaction>? transactions) {
    if (transactions != null) {
      transactions.sort((a, b) => b.date.compareTo(a.date));
      if (transactions.isEmpty) {
        return const SliverToBoxAdapter(
          child: EmptyList(urlImage: 'assets/images/new-spend.png', text: 'What will be your first spend?'),
        );
      } else {
        return SliverToBoxAdapter(
          child: Column(
            children: List.generate(
              transactions.length,
              (index) => DailyItem(transaction: transactions[index], key: Key(Random().nextDouble().toString())),
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
