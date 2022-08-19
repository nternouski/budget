import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (backPressTime != null && (now.difference(backPressTime!) < durationBackTime)) return Future.value(true);
    backPressTime = now;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Double Tap to Exit'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    final floatingActionButton = FloatingActionButton(
      onPressed: () => RouteApp.redirect(
        context: context,
        url: footer[pageIndex].actionIcon!,
        fromScaffold: false,
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add, size: 25),
    );
    return WillPopScope(
      onWillPop: () => onWillPop(),
      child: Scaffold(
        drawer: NavDrawer(),
        body: IndexedStack(index: pageIndex, children: footer.map((f) => f.widget()).toList()),
        bottomNavigationBar: getFooter(),
        floatingActionButton: footer[pageIndex].actionIcon != null ? floatingActionButton : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget getFooter() {
    final theme = Theme.of(context);
    return AnimatedBottomNavigationBar(
      activeColor: theme.colorScheme.primary,
      splashColor: theme.colorScheme.primary,
      backgroundColor: theme.backgroundColor,
      inactiveColor: theme.disabledColor,
      icons: footer.map((f) => f.icon).toList(),
      activeIndex: pageIndex,
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.softEdge,
      leftCornerRadius: 10,
      iconSize: 25,
      splashSpeedInMilliseconds: 400,
      rightCornerRadius: 10,
      onTap: (index) {
        selectedTab(footer[index].url);
      },
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
