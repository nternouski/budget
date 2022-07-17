import 'package:flutter/material.dart';
import './screens/transaction_screen.dart';
import './screens/mobile_calculator_screen.dart';
import './screens/create_or_update_transaction_screen.dart';
import './screens/create_or_update_wallet_screen.dart';
import './screens/daily_screen.dart';
import './screens/profile_screen.dart';
import './screens/stats_screen.dart';

class Footer {
  Widget widget;
  late IconData icon;

  Footer(this.widget, icon) {
    this.icon = icon ?? Icons.question_mark;
  }
}

enum URLS { calendar, stats, wallets, createOrUpdateWallet, settings, createOrUpdateTransaction, mobileCalculator }

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
    RoutePage(
        widget: DailyScreen(),
        url: URLS.calendar,
        icon: Icons.calendar_month,
        actionIcon: URLS.createOrUpdateTransaction),
    RoutePage(widget: StatsScreen(), url: URLS.stats, icon: Icons.query_stats),
    RoutePage(
        widget: TransactionScreen(), url: URLS.wallets, icon: Icons.wallet, actionIcon: URLS.createOrUpdateWallet),
    RoutePage(widget: ProfileScreen(), url: URLS.settings, icon: Icons.settings),
    // --- END FOOTER ---
    RoutePage(widget: CreateOrUpdateTransaction(), url: URLS.createOrUpdateTransaction),
    RoutePage(widget: CreatOrUpdateWalletScreen(), url: URLS.createOrUpdateWallet),
    RoutePage(widget: MobileCalculatorScreen(), url: URLS.mobileCalculator),
  ];

  static Widget getRoute(URLS url) {
    return routes.firstWhere((r) => r.url == url).widget;
  }
}
