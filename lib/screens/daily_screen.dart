import 'dart:math';
import 'package:budget/components/empty_list.dart';
import 'package:flutter/material.dart';

import '../server/model_rx.dart';
import '../common/styles.dart';
import '../components/user_login.dart';
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
    // FIXME: Hacerlo mas eficiente.
    transactionRx.getAll();
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Column(children: [
        SizedBox(
          height: 310,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                titleTextStyle: textTheme.titleLarge,
                pinned: true,
                leading: getLadingButton(context),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [Text('Daily Transaction'), UserLogin()],
                ),
              ),
              StreamBuilder<List<Transaction>>(
                stream: transactionRx.fetchRx,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    final List<Transaction> daily = List<Transaction>.from(snapshot.data!);
                    return SliverToBoxAdapter(child: SpendGraphic(transactions: daily));
                  } else {
                    return const SliverToBoxAdapter(child: Text('Hubo un error inesperado en daily_screen Graphics'));
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: getBody(),
            ),
            onRefresh: () => transactionRx.getAll(),
          ),
        )
      ]),
    );
  }

  List<Widget> getBody() {
    return [
      StreamBuilder<List<Transaction>>(
        stream: transactionRx.fetchRx,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final List<Transaction> daily = List<Transaction>.from(snapshot.data!);
            daily.sort((a, b) => b.date.compareTo(a.date));
            if (daily.isEmpty) {
              return const SliverToBoxAdapter(
                  child: EmptyList(urlImage: 'assets/images/new-spend.png', text: 'What will be your first spend?'));
            } else {
              return SliverToBoxAdapter(
                child: Column(
                  children: List.generate(
                    daily.length,
                    (index) => DailyItem(transaction: daily[index], key: Key(Random().nextDouble().toString())),
                  ),
                ),
              );
            }
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            return const SliverToBoxAdapter(child: Text('Hubo un error inesperado en daily_screen'));
          }
        },
      ),
    ];
  }
}
