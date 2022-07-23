import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import '../server/model_rx.dart';
import '../common/styles.dart';
import '../components/daily_item.dart';
import '../model/transaction.dart';
import '../components/spend_graphic.dart';
import '../common/color_constants.dart';

class DailyScreen extends StatefulWidget {
  @override
  _DailyScreenState createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  _DailyScreenState() {
    transactionRx.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(children: [
        SizedBox(
          height: 310,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: white,
                leading: getLadingButton(context),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [Text("Daily Transaction", style: titleStyle), Icon(Icons.search, color: black)],
                ),
              ),
              StreamBuilder<List<Transaction>>(
                stream: transactionRx.fetchRx,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    final List<Transaction> daily = List<Transaction>.from(snapshot.data!);
                    return SliverToBoxAdapter(child: daily.isEmpty ? const Text('No Graphics') : SpendGraphic(daily));
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
    // WiseApi().fetchTransfers().then((d) => inspect(d));
    return [
      StreamBuilder<List<Transaction>>(
        stream: transactionRx.fetchRx,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final List<Transaction> daily = List<Transaction>.from(snapshot.data!);
            daily.sort((a, b) => b.date.compareTo(a.date));
            inspect(daily);
            if (daily.isEmpty) {
              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [SizedBox(height: 60), Text('No transactions by the moment.', style: titleStyle)],
                ),
              );
            } else {
              return SliverToBoxAdapter(
                child: Column(
                  children: List.generate(
                    daily.length,
                    (index) => DailyItem(daily[index], key: Key("${Random().nextDouble()}")),
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
