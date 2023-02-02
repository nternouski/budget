import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../i18n/index.dart';
import '../common/error_handler.dart';
import '../components/daily_item.dart';
import '../model/transaction.dart';
import '../model/user.dart';
import '../model/wallet.dart';
import '../server/wise_api/helper.dart';
// import '../server/wise_api/wise_api.dart';
import '../common/styles.dart';

class WiseSyncScreen extends StatefulWidget {
  const WiseSyncScreen({Key? key}) : super(key: key);

  @override
  WiseSyncScreenState createState() => WiseSyncScreenState();
}

class StatementsRequest {
  Wallet? wallet;
  DateTime intervalStart = DateTime.now().subtract(const Duration(days: 30));
}

class WiseSyncScreenState extends State<WiseSyncScreen> {
  ValueNotifier<StatementsRequest> selected = ValueNotifier<StatementsRequest>(StatementsRequest());

  WiseSyncScreenState();

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_cast
    final user = Provider.of<User>(context) as User?;
    if (user == null) return const Text('Not User');
    String token = user.integrations[IntegrationType.wise] ?? '';
    if (token == '') HandlerError().setError('Api key not set.'.i18n);
    // WiseApi wiseApi = WiseApi(token);

    final theme = Theme.of(context);
    // final List<Wallet> wallets = Provider.of<List<Wallet>>(context);

    return Scaffold(
      body: Column(children: [
        SizedBox(
          height: 190,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                titleTextStyle: theme.textTheme.titleLarge,
                pinned: true,
                leading: getBackButton(context),
                title: Text('Wise Transactions'.i18n),
                actions: [
                  IconButton(
                    onPressed: () => _showDialog(context, selected.value.intervalStart),
                    icon: const Icon(Icons.date_range),
                  ),
                ],
              ),
              // SliverToBoxAdapter(child: getSearch(wallets))
            ],
          ),
        ),
        Image.asset('assets/images/construction.png', width: 300, height: 300),
        Text('In Construction'.i18n, style: theme.textTheme.titleMedium)
        // Expanded(
        //   child: RefreshIndicator(
        //     child: CustomScrollView(
        //       physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        //       slivers: [
        //         SliverToBoxAdapter(
        //           child: ValueListenableBuilder<StatementsRequest>(
        //             valueListenable: selected,
        //             builder: (context, value, _) {
        //               final wallet = value.wallet;
        //               if (wallet == null) return const Center(child: Text('Select Balance'));
        //               return FutureBuilder(
        //                 future: wiseApi.fetchTransfers(createdDateStart: value.intervalStart, wallet: wallet),
        //                 builder: (BuildContext context, AsyncSnapshot<List<WiseTransactions>> snapshot) {
        //                   if (snapshot.hasError) inspect(snapshot.error);
        //                   List<WiseTransactions>? data = snapshot.data;
        //                   if (data == null || !snapshot.hasData) {
        //                     return Column(children: [Progress.getLoadingProgress(context: context)]);
        //                   }
        //                   return getBody(context, data);
        //                 },
        //               );
        //             },
        //           ),
        //         )
        //       ],
        //     ),
        //     onRefresh: () async {},
        //   ),
        // )
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

  Widget getSearch(List<Wallet> wallets) {
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
