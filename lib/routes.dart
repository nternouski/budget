import 'package:flutter/material.dart';

import 'package:budget/screens/budgets_screen.dart';
import 'package:budget/screens/create_or_update_budget_screen.dart';
import 'package:budget/screens/create_or_update_transaction_screen.dart';
import 'package:budget/screens/create_or_update_wallet_screen.dart';
import 'package:budget/screens/faq_screen.dart';
import 'package:budget/screens/mobile_calculator_screen.dart';
import 'package:budget/screens/settings.dart';
import 'package:budget/screens/stats_screen.dart';
import 'package:budget/screens/wallets_screen.dart';
import 'package:budget/screens/daily_screen.dart';
import 'package:budget/screens/wise_sync.dart';

enum URLS {
  dailyTransactions,
  wiseSync,
  stats,
  wallets,
  createOrUpdateWallet,
  budgets,
  createOrUpdateBudgets,
  settings,
  createOrUpdateTransaction,
  mobileCalculator,
  faq
}

class RouteApp {
  static Map<String, Widget Function(BuildContext)> routes = {
    URLS.dailyTransactions.toString(): (context) => const DailyScreen(),
    URLS.wallets.toString(): (context) => const WalletsScreen(),
    URLS.budgets.toString(): (context) => const BudgetsScreen(),
    URLS.settings.toString(): (context) => const SettingsScreen(),
    URLS.stats.toString(): (context) => const StatsScreen(),
    URLS.wiseSync.toString(): (context) => const WiseSyncScreen(),
    URLS.createOrUpdateTransaction.toString(): (context) => const CreateOrUpdateTransaction(),
    URLS.createOrUpdateWallet.toString(): (context) => const CreateOrUpdateWalletScreen(),
    URLS.createOrUpdateBudgets.toString(): (context) => const CreateOrUpdateBudgetScreen(),
    URLS.mobileCalculator.toString(): (context) => const MobileCalculatorScreen(),
    URLS.faq.toString(): (context) => const FAQScreen(),
  };
  static redirect({required BuildContext context, required URLS url, dynamic param, bool fromScaffold = true}) {
    if (fromScaffold) Scaffold.of(context).closeDrawer(); // Paca cerrar el mat menu.
    Navigator.pushNamed(context, url.toString(), arguments: param);
  }
}
