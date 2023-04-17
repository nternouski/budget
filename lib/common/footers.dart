import 'package:budget/i18n/index.dart';
import 'package:flutter/material.dart';

import '../routes.dart';
import '../screens/create_or_update_wallet_screen.dart';
import '../screens/create_or_update_budget_screen.dart';
import '../screens/create_or_update_transaction_screen.dart';
import '../screens/settings.dart';
import '../screens/wallets_screen.dart';
import '../screens/budgets_screen.dart';
import '../screens/daily_screen.dart';

class Footer {
  final Widget Function({dynamic param}) widget;
  final URLS url;
  final Widget? actionIcon;
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
      label: 'Daily'.i18n,
      actionIcon: const CreateOrUpdateTransactionScreen()),
  Footer(
      widget: ({param}) => const WalletsScreen(),
      url: URLS.wallets,
      icon: Icons.account_balance_wallet_outlined,
      iconSelected: Icons.account_balance_wallet_rounded,
      label: 'Wallets'.i18n,
      actionIcon: const CreateOrUpdateWalletScreen()),
  Footer(
      widget: ({param}) => const BudgetsScreen(),
      url: URLS.budgets,
      icon: Icons.monitor_heart_outlined,
      iconSelected: Icons.monitor_heart_rounded,
      label: 'Budget'.i18n,
      actionIcon: const CreateOrUpdateBudgetScreen()),
  Footer(
    widget: ({param}) => const SettingsScreen(),
    url: URLS.settings,
    icon: Icons.settings_outlined,
    iconSelected: Icons.settings,
    label: 'Settings'.i18n,
  ),
];
