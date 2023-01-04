import 'package:budget/common/error_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../common/theme.dart';
import '../components/empty_list.dart';
import '../model/currency.dart';
import '../model/user.dart';
import '../server/database/user_rx.dart';
import '../server/database/wallet_rx.dart';
import '../routes.dart';
import '../common/styles.dart';
import '../components/icon_circle.dart';
import '../model/wallet.dart';

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({Key? key}) : super(key: key);

  @override
  WalletsScreenState createState() => WalletsScreenState();
}

class WalletsScreenState extends State<WalletsScreen> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    List<Wallet> wallets = Provider.of<List<Wallet>>(context);
    List<CurrencyRate> currencyRates = Provider.of<List<CurrencyRate>>(context);

    auth.User authUser = Provider.of<auth.User>(context, listen: false);
    User? user = Provider.of<User>(context);

    Widget? component;
    if (wallets.isEmpty) {
      component = const SliverToBoxAdapter(
        child: EmptyList(urlImage: 'assets/images/wallet.png', text: 'No wallets by the moment.'),
      );
    } else {
      component = SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, idx) => Padding(
            padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
            child: WalletItem(
                wallet: wallets[idx], userId: authUser.uid, showBalance: true, showActions: true, selected: true),
          ),
          childCount: wallets.length,
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverAppBar(
              titleTextStyle: textTheme.titleLarge,
              pinned: true,
              leading: getLadingButton(context),
              title: const Text('Wallets'),
            ),
            component,
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            if (user != null && user.superUser == true)
              SliverToBoxAdapter(
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ElevatedButton(
                    onPressed: () => userRx.calcWallets(user, wallets, currencyRates),
                    child: const Text('Re calculate Wallets'),
                  )
                ]),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 80))
          ],
        ),
        onRefresh: () async => setState(() {}),
      ),
    );
  }
}

class WalletItem extends StatelessWidget {
  final Wallet wallet;
  final String userId;
  final bool showBalance;
  final bool showActions;
  final bool selected;

  const WalletItem({
    Key? key,
    required this.wallet,
    required this.userId,
    required this.showBalance,
    required this.showActions,
    required this.selected,
  }) : super(key: key);

  Future<bool?> _confirm(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('This action will delete all transaction of this wallets too.'),
          actions: <Widget>[
            buttonCancelContext(context),
            ElevatedButton(
              style: ButtonThemeStyle.getStyle(ThemeTypes.warn, context),
              child: const Text('Delete'),
              onPressed: () {
                walletRx.delete(wallet.id, userId);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = selected ? wallet.color : Theme.of(context).disabledColor;
    final List<CurrencyRate> currencyRates = Provider.of<List<CurrencyRate>>(context);
    final contrastColor = TextColor.getContrastOf(color);
    User? user = Provider.of<User>(context);

    return Container(
      decoration: BoxDecoration(borderRadius: borderRadiusApp, color: color),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              child: IconCircle(icon: wallet.icon, color: contrastColor),
              onTap: () {
                if (wallet.balance.compareTo(wallet.balanceFixed) != 0) {
                  double equivalent = wallet.balanceFixed;
                  if (wallet.initialAmount != 0) {
                    CurrencyRate cr = currencyRates.findCurrencyRate(user.defaultCurrency, wallet.currency!);
                    equivalent += cr.convert(wallet.initialAmount, wallet.currencyId, user.defaultCurrency.id);
                  }
                  Display.message(
                    context,
                    'It\'s equivalent to \$${equivalent.prettier()} ${user.defaultCurrency.symbol}',
                    seconds: 4,
                  );
                }
              },
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(wallet.name, style: textTheme.titleLarge?.copyWith(color: contrastColor)),
                if (showBalance) ...[
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('\$${(wallet.balance + wallet.initialAmount).prettier()}',
                          style: textTheme.headlineSmall?.copyWith(color: contrastColor)),
                      const SizedBox(width: 5),
                      Text(wallet.currency!.symbol, style: textTheme.bodyLarge?.copyWith(color: contrastColor)),
                    ],
                  ),
                ],
              ],
            ),
            if (showActions) ...[
              const Expanded(child: Text('')),
              IconButton(
                onPressed: () => RouteApp.redirect(
                    context: context, url: URLS.createOrUpdateWallet, param: wallet, fromScaffold: false),
                icon: Icon(Icons.edit, color: contrastColor),
              ),
              IconButton(
                onPressed: () async => _confirm(context),
                icon: Icon(Icons.delete, color: contrastColor),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
