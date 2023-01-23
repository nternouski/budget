import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../i18n/index.dart';
import '../common/error_handler.dart';
import '../common/convert.dart';
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
      component = SliverToBoxAdapter(
        child: EmptyList(urlImage: 'assets/images/wallet.png', text: 'No wallets by the moment.'.i18n),
      );
    } else {
      component = SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, idx) => GestureDetector(
            onTap: () => RouteApp.redirect(
                context: context, url: URLS.createOrUpdateWallet, param: wallets[idx], fromScaffold: false),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: WalletItem(
                  wallet: wallets[idx], userId: authUser.uid, showBalance: true, showActions: true, selected: true),
            ),
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
              title: Text('Wallets'.i18n),
            ),
            component,
            if (user != null && user.superUser == true)
              SliverToBoxAdapter(
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ElevatedButton(
                    onPressed: () => userRx.calcWallets(user, wallets, currencyRates),
                    child: Text('Re calculate Wallets'.i18n),
                  )
                ]),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100))
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
          title: Text('Are you sure you want to delete?'.i18n),
          content: Text('This action will delete all transaction of this wallets too.'.i18n),
          actions: <Widget>[
            buttonCancelContext(context),
            ElevatedButton(
              style: ButtonThemeStyle.getStyle(ThemeTypes.warn, context),
              child: Text('Delete'.i18n),
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
                    '${'It\'s equivalent to'.i18n} ${equivalent.prettier(withSymbol: true)} ${user.defaultCurrency.symbol}',
                    seconds: 4,
                  );
                }
              },
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Convert.capitalize(wallet.name), style: textTheme.titleLarge?.copyWith(color: contrastColor)),
                if (showBalance) ...[
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text((wallet.balance + wallet.initialAmount).prettier(withSymbol: true),
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
