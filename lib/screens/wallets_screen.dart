import 'package:flutter/material.dart';
import '../routes.dart';
import '../common/styles.dart';
import '../common/color_constants.dart';
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
    walletRx.getAll();
    return Scaffold(
      backgroundColor: backgroundColor,
      body: RefreshIndicator(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: getBody(),
        ),
        onRefresh: () => walletRx.getAll(),
      ),
    );
  }

  List<Widget> getBody() {
    return [
      SliverAppBar(
        pinned: true,
        backgroundColor: white,
        leading: getLadingButton(context),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [Text('Wallets', style: titleStyle)],
        ),
      ),
      StreamBuilder<List<Wallet>>(
        stream: walletRx.fetchRx,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final wallets = List<Wallet>.from(snapshot.data!);
            if (wallets.isEmpty) {
              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [SizedBox(height: 60), Text('No wallets by the moment.', style: titleStyle)],
                ),
              );
            } else {
              return SliverList(
                delegate: SliverChildBuilderDelegate((_, idx) => getWallet(wallets[idx]), childCount: wallets.length),
              );
            }
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            return const SliverToBoxAdapter(child: Text('Hubo un error inesperado en wallets_screen'));
          }
        },
      ),
    ];
  }

  Padding getWallet(Wallet wallet) {
    String symbol = wallet.currency!.symbol;
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(12), boxShadow: [
          BoxShadow(color: grey.withOpacity(0.01), spreadRadius: 10, blurRadius: 3),
        ]),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconCircle(icon: wallet.icon, color: wallet.color),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(wallet.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('\$${wallet.balance}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      const SizedBox(width: 5),
                      Text(symbol, style: textGreyStyle)
                    ],
                  ),
                ],
              ),
              const Expanded(child: Text('')),
              IconButton(
                onPressed: () => RouteApp.redirect(
                    context: context, url: URLS.createOrUpdateWallet, param: wallet, fromScaffold: false),
                icon: const Icon(Icons.edit, color: grey),
              ),
              IconButton(onPressed: () => walletRx.delete(wallet.id), icon: const Icon(Icons.delete, color: grey)),
            ],
          ),
        ),
      ),
    );
  }
}
