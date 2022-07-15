import 'package:budget/screens/mobile_calculator_screen.dart';
import 'package:flutter/material.dart';
import '../screens/budget_screen.dart';
import '../screens/create_or_update_budget_screen.dart';
import '../screens/create_or_update_wallet_screen.dart';
import '../screens/daily_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/stats_screen.dart';

class Footer {
  Widget widget;
  late IconData icon;

  Footer(this.widget, icon) {
    this.icon = icon ?? Icons.question_mark;
  }
}

enum URLS { calendar, stats, wallets, createOrUpdateWallet, settings, createOrUpdateBudget, mobileCalculator }

class RoutePage extends Footer {
  URLS url;
  late bool onFooter;
  URLS? actionIcon;

  RoutePage({required Widget widget, required this.url, IconData? icon, this.actionIcon}) : super(widget, icon) {
    onFooter = icon != null;
  }
}

class RouteApp {
  static List<RoutePage> routes = [
    // The first Fours should be the footers
    RoutePage(widget: DailyScreen(), url: URLS.calendar, icon: Icons.calendar_month, actionIcon: URLS.createOrUpdateBudget),
    RoutePage(widget: StatsScreen(), url: URLS.stats, icon: Icons.query_stats),
    RoutePage(widget: BudgetScreen(), url: URLS.wallets, icon: Icons.wallet, actionIcon: URLS.createOrUpdateWallet),
    RoutePage(widget: ProfileScreen(), url: URLS.settings, icon: Icons.settings),
    // --- END FOOTER ---
    RoutePage(widget: CreateOrUpdateBudget(), url: URLS.createOrUpdateBudget),
    RoutePage(widget: CreatOrUpdateWalletScreen(), url: URLS.createOrUpdateWallet),
    RoutePage(widget: MobileCalculatorScreen(), url: URLS.mobileCalculator),
  ];

  static Widget getRoute(URLS url) {
    return routes.firstWhere((r) => r.url == url).widget;
  }
}
