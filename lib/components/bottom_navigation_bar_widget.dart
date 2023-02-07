import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../i18n/index.dart';
import '../common/ad_helper.dart';
import '../common/version_checker.dart';
import '../common/error_handler.dart';
import '../common/theme.dart';
import '../common/convert.dart';
import '../common/footers.dart';
import '../model/user.dart';
import '../routes.dart';
import './nav_draw.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  const BottomNavigationBarWidget({Key? key}) : super(key: key);

  @override
  BottomNavigationBarWidgetState createState() => BottomNavigationBarWidgetState();
}

class BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  int pageIndex = 0;
  DateTime? backPressTime;
  final durationBackTime = const Duration(seconds: 2);
  BannerAd? banner;
  int _bannerAdRetry = 0;

  BottomNavigationBarWidgetState() {
    assert(footer.length == 4);
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (backPressTime != null && (now.difference(backPressTime!) < durationBackTime)) return Future.value(true);
    backPressTime = now;
    Display.message(context, 'Double Tap to Exit'.i18n);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final adState = Provider.of<AdStateNotifier>(context);
    // ignore: unnecessary_cast
    bool showAds = (Provider.of<User>(context) as User?)?.showAds() ?? true;

    if (showAds && banner == null && _bannerAdRetry <= AdStateNotifier.MAXIMUM_NUMBER_OF_AD_REQUEST) {
      _bannerAdRetry++;
      banner = BannerAd(
          size: AdSize(height: AdSize.banner.height, width: MediaQuery.of(context).size.width.toInt()),
          adUnitId: adState.bannerAdUnitId,
          listener: adState.bannerAdListener(onFailed: () {
            setState(() {
              banner = null;
            });
          }),
          request: const AdRequest())
        ..load();
    }

    final floatingActionButton = FloatingActionButton(
      onPressed: () => RouteApp.redirect(context: context, url: footer[pageIndex].actionIcon!, fromScaffold: false),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add, size: 25),
    );

    return WillPopScope(
      onWillPop: () => onWillPop(),
      child: Scaffold(
        extendBody: true,
        drawer: NavDrawer(),
        body: IndexedStack(index: pageIndex, children: footer.map((f) => f.widget()).toList()),
        bottomNavigationBar: getFooter(context, theme),
        floatingActionButton: footer[pageIndex].actionIcon != null ? floatingActionButton : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget getFooter(BuildContext context, ThemeData theme) {
    Color backgroundColor;
    if (Provider.of<ThemeProvider>(context).themeMode == ThemeMode.light) {
      var temp = Convert.increaseColorLightness(theme.colorScheme.primary, 0.55);
      backgroundColor = Convert.increaseColorSaturation(temp, -0.5);
    } else {
      backgroundColor = Convert.increaseColorLightness(theme.colorScheme.primary, -0.18);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBottomNavigationBar(
          activeColor: theme.colorScheme.primary,
          splashColor: theme.colorScheme.primary,
          backgroundColor: backgroundColor,
          inactiveColor: theme.hintColor.withOpacity(0.2),
          icons: footer.map((f) => f.icon).toList(),
          activeIndex: pageIndex,
          gapLocation: GapLocation.center,
          notchSmoothness: NotchSmoothness.softEdge,
          leftCornerRadius: 10,
          iconSize: 25,
          splashSpeedInMilliseconds: 200,
          rightCornerRadius: 10,
          onTap: (index) => selectedTab(footer[index].url),
        ),
        if (banner != null)
          Container(
            height: banner!.size.height.toDouble(),
            color: theme.scaffoldBackgroundColor,
            child: AdWidget(ad: banner!),
          ),
      ],
    );
  }

  selectedTab(URLS url) {
    setState(() {
      var indexFound = footer.indexWhere((r) => r.url == url);
      if (indexFound != -1) {
        pageIndex = indexFound;
      } else {
        debugPrint('Route $url Not Found!');
      }
    });
  }
}
