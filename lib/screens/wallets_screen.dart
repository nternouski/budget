import 'package:budget/common/theme.dart';
import 'package:budget/components/empty_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../routes.dart';
import '../common/styles.dart';
import '../components/icon_circle.dart';
import '../model/wallet.dart';
import '../server/model_rx.dart';

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
            child: WalletItem(wallet: wallets[idx], showBalance: true, showActions: true, selected: true),
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
            component
          ],
        ),
        onRefresh: () => walletRx.getAll(),
      ),
    );
  }
}

class WalletItem extends StatelessWidget {
  final Wallet wallet;
  final bool showBalance;
  final bool showActions;
  final bool selected;

  const WalletItem({
    Key? key,
    required this.wallet,
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
                walletRx.delete(wallet.id);
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
    final contrastColor = TextColor.getContrastOf(color);
    return Container(
      decoration: BoxDecoration(borderRadius: borderRadiusApp, color: color),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconCircle(icon: wallet.icon, color: contrastColor),
            const SizedBox(width: 15),
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
                      Text('\$${wallet.balance.floor()}',
                          style: textTheme.headlineSmall?.copyWith(color: contrastColor)),
                      const SizedBox(width: 5),
                      Text(wallet.currency!.symbol, style: textTheme.bodyLarge?.copyWith(color: contrastColor))
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
