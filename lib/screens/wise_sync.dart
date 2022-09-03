import 'dart:developer';
import 'package:budget/common/theme.dart';
import 'package:budget/components/daily_item.dart';
import 'package:budget/model/integration.dart';
import 'package:budget/model/transaction.dart';
import 'package:budget/model/user.dart';
import 'package:budget/model/wallet.dart';
import 'package:budget/server/wise_api/helper.dart';
import 'package:budget/server/wise_api/wise_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/styles.dart';

class WiseSyncScreen extends StatefulWidget {
  const WiseSyncScreen({Key? key}) : super(key: key);

  @override
  WiseSyncScreenState createState() => WiseSyncScreenState();
}

class StatementsRequest {
  WiseBalance? balance;
  Wallet? wallet;
  DateTime intervalStart = DateTime.now().subtract(const Duration(days: 30));
}

class WiseSyncScreenState extends State<WiseSyncScreen> {
  ValueNotifier<StatementsRequest> selected = ValueNotifier<StatementsRequest>(StatementsRequest());

  WiseSyncScreenState();

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<User>(context);
    if (user == null) return const Text('Not User');
    var wise = user.integrations.firstWhere(
      (i) => i.integrationType == IntegrationType.wise,
      orElse: () => Integration.wise(user.id),
    );
    WiseApi wiseApi = WiseApi(wise.apiKey);
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(children: [
        SizedBox(
          height: 280,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                titleTextStyle: theme.textTheme.titleLarge,
                pinned: true,
                leading: getBackButton(context),
                title: const Text('Wise Transactions'),
                actions: [
                  IconButton(
                    onPressed: () => _showDialog(context, selected.value.intervalStart),
                    icon: const Icon(Icons.date_range),
                  ),
                ],
              ),
              FutureBuilder(
                future: wiseApi.fetchBalance(),
                builder: (BuildContext context, AsyncSnapshot<List<WiseProfileBalance>> snapshot) {
                  if (snapshot.hasError) inspect(snapshot.error);
                  return SliverToBoxAdapter(child: getSearch(context, snapshot.data ?? [], !snapshot.hasData));
                },
              )
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(
                  child: ValueListenableBuilder<StatementsRequest>(
                    valueListenable: selected,
                    builder: (context, value, _) {
                      final balance = value.balance;
                      final wallet = value.wallet;
                      if (balance == null || wallet == null) {
                        return const Center(child: Text('Select Balance and Wallet'));
                      }
                      return FutureBuilder(
                        future: wiseApi.fetchBalanceStatements(
                          balance: balance,
                          intervalStart: value.intervalStart,
                          walletId: wallet.id,
                        ),
                        builder: (BuildContext context, AsyncSnapshot<List<WiseTransactions>> snapshot) {
                          if (snapshot.hasError) inspect(snapshot.error);
                          var data = snapshot.data;
                          if (data == null || !snapshot.hasData) {
                            return Column(children: [Progress.getLoadingProgress(context: context)]);
                          }
                          return getBody(context, data);
                        },
                      );
                    },
                  ),
                )
              ],
            ),
            onRefresh: () async {},
          ),
        )
      ]),
    );
  }

  _showDialog(BuildContext context, DateTime date) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != date) {
      selected.value.intervalStart = picked;
      selected.notifyListeners();
    }
  }

  Widget getSearch(BuildContext context, List<WiseProfileBalance> data, bool loading) {
    List<Wallet> wallets = Provider.of<List<Wallet>>(context);
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(children: [
        InputDecorator(
          decoration: const InputDecoration(labelText: 'Select Wallet'),
          child: ValueListenableBuilder<StatementsRequest>(
            valueListenable: selected,
            builder: (context, value, _) {
              return DropdownButtonHideUnderline(
                child: DropdownButton<Wallet>(
                  value: value.wallet,
                  isDense: true,
                  onChanged: (Wallet? w) {
                    if (w != null) {
                      selected.value.wallet = w;
                      selected.notifyListeners();
                    }
                  },
                  items: wallets.map((wallet) => DropdownMenuItem(value: wallet, child: Text(wallet.name))).toList(),
                ),
              );
            },
          ),
        ),
        Row(
          children: [
            Expanded(
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Select Balance'),
                child: DropdownButtonHideUnderline(
                  child: ValueListenableBuilder<StatementsRequest>(
                    valueListenable: selected,
                    builder: (context, value, _) {
                      return DropdownButton<WiseBalance?>(
                        value: value.balance,
                        isDense: true,
                        onChanged: (WiseBalance? b) {
                          if (b != null) {
                            selected.value.balance = b;
                            selected.notifyListeners();
                          }
                        },
                        items: data
                            .map(
                              (profileB) {
                                var options = profileB.balances
                                    .map((b) => DropdownMenuItem(value: b, child: Text('-     ${b.currency}')))
                                    .toList();
                                return [
                                  DropdownMenuItem(
                                    value: null,
                                    enabled: false,
                                    child: Text(profileB.profile.fullName, style: const TextStyle(color: Colors.grey)),
                                  ),
                                  ...options
                                ];
                              },
                            )
                            .expand((element) => element)
                            .toList(),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (loading) Progress.getLoadingProgress(context: context, size: 30)
          ],
        ),
      ]),
    );
  }

  Widget getBody(BuildContext context, List<WiseTransactions> wt) {
    List<Transaction>? list = Provider.of<List<Transaction>>(context);
    List<WiseTransactions> transactions =
        wt.where((t) => list.where((l) => l.externalId == t.externalId).isEmpty).toList();
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: List.generate(
          transactions.length,
          (index) => DailyItem(transaction: transactions[index], action: ' Create', actionIcon: Icons.wallet_rounded),
        ),
      ),
    );
  }
}
