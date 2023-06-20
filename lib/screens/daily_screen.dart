import 'package:budget/common/ad_helper.dart';
import 'package:budget/common/device_info_notifier.dart';
import 'package:budget/common/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../i18n/index.dart';
import '../common/classes.dart';
import '../common/period_stats.dart';
import '../common/preference.dart';
import '../components/empty_list.dart';
import '../model/wallet.dart';
import '../model/user.dart';
import '../server/database/transaction_rx.dart';
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
  bool fetchAll = false;
  List<Transaction> transactions = List.from([]);

  List<NativeAd>? nativeBanners;
  int _nativeAdRetry = 0;
  int adsLoaded = 0;
  final int showAdsEach = 7;

  DailyScreenState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradientPrimary = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0, 0.15],
        colors: [
          theme.colorScheme.primary.withOpacity(OPACITY),
          theme.colorScheme.primary.withOpacity(0.0),
        ],
      ),
    );
    final gradientDisappear = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0, 0.15],
        colors: [
          theme.scaffoldBackgroundColor,
          theme.scaffoldBackgroundColor.withOpacity(0.0),
        ],
      ),
    );

    User? user = Provider.of<User>(context) as dynamic;
    List<Wallet> wallets = List.from(Provider.of<List<Wallet>>(context));
    if (user == null) return ScreenInit.getScreenInit(context);

    // ignore: unnecessary_cast
    bool showAds = (Provider.of<User>(context) as User?)?.showAds() ?? true;

    return Scaffold(
      appBar: AppBar(
        titleTextStyle: theme.textTheme.titleLarge,
        leading: getLadingButton(context),
        title: Text('Daily Transaction'.i18n),
        actions: [
          if (user.superUser)
            IconButton(
              onPressed: () => RouteApp.redirect(context: context, url: URLS.stats),
              icon: const Icon(Icons.query_stats),
              tooltip: 'Go to Stats'.i18n,
            ),
          if (!fetchAll)
            IconButton(
              onPressed: () => setState(() => fetchAll = true),
              icon: const Icon(Icons.download_rounded),
              tooltip: 'See All'.i18n,
            ),
        ],
      ),
      body: Column(children: [
        ValueListenableBuilder<PeriodStats>(
          valueListenable: periods.selected,
          builder: (context, periodStats, child) => SpendGraphic(
            frameRange: periodStats.days,
            user: user,
            key: Key(periodStats.days.toString()),
          ),
        ),
        Expanded(
          child: Container(
            foregroundDecoration: gradientPrimary,
            child: Container(
              foregroundDecoration: gradientDisappear,
              child: RefreshIndicator(
                child: getBody(theme, user, wallets, showAds),
                onRefresh: () async => setState(() {}),
              ),
            ),
          ),
        )
      ]),
    );
  }

  Widget getBody(ThemeData themeData, User user, List<Wallet> wallets, bool showAds) {
    final deviceInfo = Provider.of<DeviceInfoNotifier>(context);
    final adState = Provider.of<AdStateNotifier>(context);
    final theme = Provider.of<ThemeProvider>(context);

    return StreamBuilder<List<Transaction>>(
      stream: transactionRx.getTransactions(user.id, fetchAll: fetchAll),
      builder: (BuildContext context, snapshot) {
        List<Transaction> transactions = List.castFrom(snapshot.data ?? []);
        final canInit = showAds &&
            transactions.isNotEmpty &&
            _nativeAdRetry <= AdStateNotifier.MAXIMUM_NUMBER_OF_AD_REQUEST &&
            deviceInfo.isPhysicalDevice;

        final cantOfBanners = (transactions.length + 1) ~/ showAdsEach;
        final createdAmount = nativeBanners?.length ?? 0;
        if (canInit) {
          nativeBanners ??= List.from([]);
          for (int i = 0; i < (cantOfBanners - createdAmount); i++) {
            nativeBanners!.add(
              NativeAd(
                adUnitId: adState.nativeAdUnitId,
                factoryId: 'listTile',
                listener: adState.nativeAdListener(
                  onAdLoaded: () => setState(() => adsLoaded++),
                  onFailed: () => setState(() {
                    _nativeAdRetry++;
                    nativeBanners = null;
                  }),
                ),
                request: const AdRequest(),
                customOptions: {'darkMode': theme.isDarkMode(context)},
              )..load(),
            );
          }
        }
        transactions.sort((a, b) => b.date.compareTo(a.date));

        if (transactions.isEmpty) {
          return EmptyList(urlImage: 'assets/images/new-spend.png', text: 'What will be your first spend?'.i18n);
        } else {
          return ListView.separated(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            shrinkWrap: true,
            itemCount: transactions.length,
            separatorBuilder: (context, index) {
              // Show ads each ${showAdsEach} items counting from n = showAdsEach
              if ((index + 1) % showAdsEach == 0 && nativeBanners != null) {
                final native = nativeBanners?[(((index + 1) / showAdsEach) - 1).toInt()];
                if (native == null || adsLoaded != nativeBanners?.length) return Container();
                return Container(
                  height: 45,
                  color: themeData.scaffoldBackgroundColor,
                  child: AdWidget(ad: native),
                );
              } else {
                return Container();
              }
            },
            itemBuilder: (context, index) {
              return DailyItem(transaction: transactions[index], key: Key(transactions[index].id));
            },
          );
        }
      },
    );
  }
}
