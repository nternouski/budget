import 'package:budget/screens/create_or_update_budget_screen.dart';
import 'package:budget/screens/wallets_screen.dart';
import 'package:flutter/material.dart';
import './screens/budgets_screen.dart';
import './screens/mobile_calculator_screen.dart';
import './screens/create_or_update_transaction_screen.dart';
import './screens/create_or_update_wallet_screen.dart';
import './screens/daily_screen.dart';
import './screens/profile_screen.dart';
import './screens/stats_screen.dart';

enum URLS {
  dailyTransactions,
  stats,
  wallets,
  createOrUpdateWallet,
  budgets,
  createOrUpdateBudgets,
  settings,
  createOrUpdateTransaction,
  mobileCalculator
}

class RoutePage {
  Widget Function({dynamic param}) widget;
  URLS url;
  URLS? actionIcon;
  late IconData icon;
  late bool onFooter;

  RoutePage({required this.widget, required this.url, IconData? icon, this.actionIcon}) {
    onFooter = icon != null;
    this.icon = icon ?? Icons.question_mark;
  }
}

class RouteApp {
  static List<RoutePage> routes = [
    // The first Fours should be the footers
    RoutePage(
        widget: ({param}) => DailyScreen(),
        url: URLS.dailyTransactions,
        icon: Icons.calendar_month,
        actionIcon: URLS.createOrUpdateTransaction),
    RoutePage(
        widget: ({param}) => WalletsScreen(),
        url: URLS.wallets,
        icon: Icons.wallet,
        actionIcon: URLS.createOrUpdateWallet),
    RoutePage(
        widget: ({param}) => BudgetsScreen(),
        url: URLS.budgets,
        icon: Icons.monitor_heart,
        actionIcon: URLS.createOrUpdateBudgets),
    RoutePage(widget: ({param}) => ProfileScreen(), url: URLS.settings, icon: Icons.settings),
    // --- END FOOTER ---
    RoutePage(widget: ({param}) => StatsScreen(), url: URLS.stats),
    RoutePage(widget: ({param}) => CreateOrUpdateTransaction(transaction: param), url: URLS.createOrUpdateTransaction),
    RoutePage(widget: ({param}) => CreateOrUpdateWalletScreen(wallet: param), url: URLS.createOrUpdateWallet),
    RoutePage(widget: ({param}) => CreateOrUpdateBudgetScreen(budget: param), url: URLS.createOrUpdateBudgets),
    RoutePage(widget: ({param}) => MobileCalculatorScreen(), url: URLS.mobileCalculator),
  ];

  static Widget getRoute(URLS url, dynamic param) {
    return routes.firstWhere((r) => r.url == url).widget(param: param);
  }

  static redirect({required BuildContext context, required URLS url, dynamic param, bool fromScaffold = true}) {
    if (fromScaffold) Scaffold.of(context).closeDrawer(); // Paca cerrar el mat menu.
    Navigator.of(context).push(
      MaterialPageRoute(fullscreenDialog: true, builder: (context) => RouteApp.getRoute(url, param)),
    );
  }
}
