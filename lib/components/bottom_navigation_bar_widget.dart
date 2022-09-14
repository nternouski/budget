import 'package:budget/common/error_handler.dart';
import 'package:budget/common/theme.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';

import '../common/convert.dart';
import '../routes.dart';
import '../common/footers.dart';
import 'nav_draw.dart';

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
    Display.message(context, 'Double Tap to Exit');
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        bottomNavigationBar: getFooter(theme),
        floatingActionButton: footer[pageIndex].actionIcon != null ? floatingActionButton : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget getFooter(ThemeData theme) {
    Color backgroundColor;
    if (Provider.of<ThemeProvider>(context).themeMode == ThemeMode.light) {
      var temp = Convert.increaseColorLightness(theme.backgroundColor, 0.55);
      backgroundColor = Convert.increaseColorSaturation(temp, -0.5);
    } else {
      backgroundColor = Convert.increaseColorLightness(theme.backgroundColor, -0.18);
    }

    return AnimatedBottomNavigationBar(
      activeColor: theme.colorScheme.primary,
      splashColor: theme.colorScheme.primary,
      backgroundColor: backgroundColor,
      inactiveColor: theme.disabledColor,
      icons: footer.map((f) => f.icon).toList(),
      activeIndex: pageIndex,
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.softEdge,
      leftCornerRadius: 10,
      iconSize: 25,
      splashSpeedInMilliseconds: 200,
      rightCornerRadius: 10,
      onTap: (index) => selectedTab(footer[index].url),
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
