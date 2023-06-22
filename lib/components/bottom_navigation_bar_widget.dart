import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';

import '../i18n/index.dart';
import '../common/ad_helper.dart';
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

    Widget? floatingActionButton;
    if (footer[pageIndex].actionIcon != null) {
      floatingActionButton = OpenContainer(
        transitionType: ContainerTransitionType.fade,
        openBuilder: (BuildContext context, VoidCallback _) => footer[pageIndex].actionIcon!,
        closedElevation: 6.0,
        closedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(60 / 2)),
        ),
        closedColor: theme.colorScheme.primary,
        closedBuilder: (BuildContext context, VoidCallback openContainer) {
          return FloatingActionButton.extended(
            onPressed: openContainer,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            label: Text(footer[pageIndex].label),
            isExtended: true,
            icon: const Icon(Icons.add, size: 25),
          );
        },
      );
    }

    return WillPopScope(
      onWillPop: () => onWillPop(),
      child: Scaffold(
        extendBody: true,
        drawer: NavDrawer(),
        body: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (
            Widget child,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return FadeThroughTransition(animation: animation, secondaryAnimation: secondaryAnimation, child: child);
          },
          child: footer[pageIndex].widget(),
        ),
        bottomNavigationBar: getFooter(context, theme, pageIndex),
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      ),
    );
  }

  Widget getFooter(BuildContext context, ThemeData theme, int pageIndex) {
    Color backgroundColor;
    // TODO: fix background color when initialize for the first time
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
        BottomNavigationBar(
          items: List.generate(
            footer.length,
            (idx) => BottomNavigationBarItem(
              icon: Icon(footer[idx].url == footer[pageIndex].url ? footer[idx].iconSelected : footer[idx].icon),
              tooltip: footer[idx].label,
              label: footer[idx].label,
              backgroundColor: backgroundColor,
            ),
          ).toList(),
          currentIndex: pageIndex,
          unselectedItemColor: theme.hintColor.withOpacity(0.4),
          selectedItemColor: theme.textTheme.titleLarge?.color,
          onTap: (index) => selectedTab(footer[index].url),
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
