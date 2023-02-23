import 'package:flutter/material.dart';

import '../screens/email_verification_screen.dart';
import '../screens/budgets_screen.dart';
import '../screens/create_or_update_budget_screen.dart';
import '../screens/create_or_update_transaction_screen.dart';
import '../screens/create_or_update_wallet_screen.dart';
import '../screens/faq_screen.dart';
import '../screens/mobile_calculator_screen.dart';
import '../screens/settings.dart';
import '../screens/stats_screen.dart';
import '../screens/wallets_screen.dart';
import '../screens/daily_screen.dart';
import '../screens/wise_sync.dart';
import '../screens/expense_prediction_screen.dart';

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
  faq,
  emailVerification,
  expensePrediction
}

class RouteApp {
  static Map<String, Widget Function(BuildContext)> routes = {
    URLS.dailyTransactions.toString(): (context) => const DailyScreen(),
    URLS.wallets.toString(): (context) => const WalletsScreen(),
    URLS.budgets.toString(): (context) => const BudgetsScreen(),
    URLS.settings.toString(): (context) => const SettingsScreen(),
    URLS.stats.toString(): (context) => const StatsScreen(),
    URLS.wiseSync.toString(): (context) => const WiseSyncScreen(),
    URLS.createOrUpdateTransaction.toString(): (context) => const CreateOrUpdateTransactionScreen(),
    URLS.createOrUpdateWallet.toString(): (context) => const CreateOrUpdateWalletScreen(),
    URLS.createOrUpdateBudgets.toString(): (context) => const CreateOrUpdateBudgetScreen(),
    URLS.mobileCalculator.toString(): (context) => const MobileCalculatorScreen(),
    URLS.faq.toString(): (context) => const FAQScreen(),
    URLS.emailVerification.toString(): (context) => const EmailVerificationScreen(),
    URLS.expensePrediction.toString(): (context) => const ExpensePredictionScreenState(),
  };
  static redirect({required BuildContext context, required URLS url, dynamic param, bool fromScaffold = true}) {
    if (fromScaffold) Scaffold.of(context).closeDrawer(); // Paca cerrar el mat menu.
    Navigator.pushNamed(context, url.toString(), arguments: param);
  }
}
