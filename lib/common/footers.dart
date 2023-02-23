import 'package:flutter/material.dart';

import 'package:budget/routes.dart';
import 'package:budget/screens/settings.dart';
import 'package:budget/screens/wallets_screen.dart';
import '../screens/budgets_screen.dart';
import '../screens/daily_screen.dart';

class Footer {
  final Widget Function({dynamic param}) widget;
  final URLS url;
  final URLS? actionIcon;
  final String label;

  final IconData icon;
  late IconData iconSelected;

  Footer({
    required this.widget,
    required this.url,
    required this.icon,
    required this.label,
    this.actionIcon,
    IconData? iconSelected,
  }) {
    this.iconSelected = iconSelected ?? icon;
  }
}

List<Footer> footer = [
  Footer(
      widget: ({param}) => const DailyScreen(),
      url: URLS.dailyTransactions,
      icon: Icons.calendar_today_outlined,
      iconSelected: Icons.calendar_month,
      label: 'Daily',
      actionIcon: URLS.createOrUpdateTransaction),
  Footer(
      widget: ({param}) => const WalletsScreen(),
      url: URLS.wallets,
      icon: Icons.account_balance_wallet_outlined,
      iconSelected: Icons.account_balance_wallet_rounded,
      label: 'Wallets',
      actionIcon: URLS.createOrUpdateWallet),
  Footer(
      widget: ({param}) => const BudgetsScreen(),
      url: URLS.budgets,
      icon: Icons.monitor_heart_outlined,
      iconSelected: Icons.monitor_heart_rounded,
      label: 'Budget',
      actionIcon: URLS.createOrUpdateBudgets),
  Footer(
    widget: ({param}) => const SettingsScreen(),
    url: URLS.settings,
    icon: Icons.settings_outlined,
    iconSelected: Icons.settings,
    label: 'Settings',
  ),
];
