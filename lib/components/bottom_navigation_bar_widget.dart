import 'dart:ffi';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

import '../routes.dart';
import 'nav_draw.dart';
import '../common/color_constants.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  @override
  _BottomNavigationBarWidgetState createState() => _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  int pageIndex = 0;
  DateTime? backPressTime;
  final durationBackTime = const Duration(seconds: 2);

  final List<RoutePage> footer = RouteApp.routes.where((f) => f.onFooter).toList();

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
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    final floatingActionButton = FloatingActionButton(
      onPressed: () =>
          RouteApp.redirect(context: context, url: RouteApp.routes[pageIndex].actionIcon!, fromScaffold: false),
      backgroundColor: primary,
      child: const Icon(Icons.add, size: 25),
    );
    return WillPopScope(
      onWillPop: () => onWillPop(),
      child: Scaffold(
        drawer: NavDrawer(),
        body: IndexedStack(index: pageIndex, children: RouteApp.routes.map((f) => f.widget()).toList()),
        bottomNavigationBar: getFooter(),
        floatingActionButton: RouteApp.routes[pageIndex].actionIcon != null ? floatingActionButton : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget getFooter() {
    return AnimatedBottomNavigationBar(
      activeColor: primary,
      splashColor: secondary,
      inactiveColor: Colors.black.withOpacity(0.5),
      icons: footer.map((f) => f.icon).toList(),
      activeIndex: pageIndex,
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.softEdge,
      leftCornerRadius: 10,
      iconSize: 25,
      rightCornerRadius: 10,
      onTap: (index) {
        selectedTab(footer[index].url);
      },
    );
  }

  selectedTab(URLS? url) {
    if (url != null) {
      setState(() {
        var indexFound = RouteApp.routes.indexWhere((r) => r.url == url);
        if (indexFound != -1) {
          pageIndex = indexFound;
        } else {
          print("Route $url Not Found!");
        }
      });
    }
  }
}
