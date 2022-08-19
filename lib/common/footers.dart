import 'package:flutter/material.dart';

import 'package:budget/routes.dart';
import 'package:budget/screens/settings.dart';
import 'package:budget/screens/wallets_screen.dart';
import '../screens/budgets_screen.dart';
import '../screens/daily_screen.dart';

class Footer {
  Widget Function({dynamic param}) widget;
  URLS url;
  URLS? actionIcon;
  late IconData icon;
  late bool onFooter;

  Footer({required this.widget, required this.url, IconData? icon, this.actionIcon}) {
    onFooter = icon != null;
    this.icon = icon ?? Icons.question_mark;
  }
}

List<Footer> footer = [
  Footer(
      widget: ({param}) => const DailyScreen(),
      url: URLS.dailyTransactions,
      icon: Icons.calendar_month,
      actionIcon: URLS.createOrUpdateTransaction),
  Footer(
      widget: ({param}) => const WalletsScreen(),
      url: URLS.wallets,
      icon: Icons.wallet,
      actionIcon: URLS.createOrUpdateWallet),
  Footer(
      widget: ({param}) => const BudgetsScreen(),
      url: URLS.budgets,
      icon: Icons.monitor_heart,
      actionIcon: URLS.createOrUpdateBudgets),
  Footer(widget: ({param}) => const SettingsScreen(), url: URLS.settings, icon: Icons.settings),
];
