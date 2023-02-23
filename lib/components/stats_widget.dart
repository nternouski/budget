import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../i18n/index.dart';
import '../common/error_handler.dart';
import '../common/convert.dart';
import '../common/period_stats.dart';
import '../common/prediction_on_stats.dart';
import '../common/styles.dart';
import '../model/expense_prediction.dart';
import '../model/user.dart';
import '../model/transaction.dart';
import '../model/currency.dart';
import '../server/database/transaction_rx.dart';

class StatsPrediction extends StatelessWidget {
  final double totalExpensePeriod;
  final PeriodStats periodStats;

  const StatsPrediction({required this.totalExpensePeriod, required this.periodStats, super.key});

  @override
  Widget build(BuildContext context) {
    final predictionOnStats = Provider.of<PredictionOnStatsNotifier>(context);
    final temp = Provider.of<List<ExpensePrediction>>(context);

    if (!predictionOnStats.enable || temp.isEmpty) return const SizedBox();

    List<CurrencyRate> currencyRates = Provider.of<List<CurrencyRate>>(context);
    List<Currency> currencies = Provider.of<List<Currency>>(context);
    // ignore: unnecessary_cast
    final user = Provider.of<User>(context) as User?;
    if (user == null) return getLoadingProgress(context: context);

    Currency pCurrency = currencies.firstWhere((c) => c.id == temp[0].currencyId, orElse: () => user.defaultCurrency);

    final groups =
        temp[0].groups.map((g) => ExpensePredictionGroupTotal.fromExpensePredictionGroup(g, periodStats.days)).toList();
    final prediction = groups.fold<double>(0.0, (acc, g) => acc + g.updateTotal(periodStats.days));

    double balancePrediction = 0.0;
    try {
      CurrencyRate cr = currencyRates.findCurrencyRate(pCurrency, user.defaultCurrency);
      double converted = cr.convert(prediction, pCurrency.id, user.defaultCurrency.id);
      balancePrediction = converted - totalExpensePeriod;
    } catch (e) {
      balancePrediction = prediction - totalExpensePeriod;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 15, left: 30, right: 30),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(radiusApp)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          final p = prediction.prettier(withSymbol: true, withoutDecimal: true);
          final t = totalExpensePeriod.prettier(withSymbol: true, withoutDecimal: true);
          final r = balancePrediction.prettier(withSymbol: true, withoutDecimal: true);
          final text = '  $p = prediction \n- $t = totalExpensePeriod \n  ----------- \n  $r';
          Display.message(context, text);
        },
        child: getCardContent(context, balancePrediction),
      ),
    );
  }

  Widget getCardContent(BuildContext context, double balancePrediction) {
    final theme = Theme.of(context);
    var color = balancePrediction.isNegative ? theme.colorScheme.error : theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 5),
      child: Column(
        children: [
          Text(
            'Balance ${'Expense Simulation'.i18n}',
            style: theme.textTheme.bodyMedium!.copyWith(color: theme.hintColor),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                balancePrediction.isNegative ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                size: 30,
                color: color,
              ),
              const SizedBox(width: 5),
              balancePrediction.prettierToText(
                withSymbol: true,
                withoutDecimal: true,
                style: theme.textTheme.headlineSmall!.copyWith(color: color),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class StatsBalance extends StatelessWidget {
  final List<Transaction> transactions;
  const StatsBalance({required this.transactions, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final maxPeriodBalance = (TransactionRx.windowFetchTransactions.inDays / 30).floor();
    final balance = transactions.fold(0.0, (acc, t) => acc + t.getBalanceFromType());
    final color = balance.isNegative ? theme.colorScheme.error : theme.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 15, left: 30, right: 30),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(radiusApp)),
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 5),
        child: Column(
          children: [
            Text(
              'The Last %d months'.plural(maxPeriodBalance),
              style: theme.textTheme.bodyMedium!.copyWith(color: theme.hintColor),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  balance.isNegative ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                  size: 30,
                  color: color,
                ),
                const SizedBox(width: 5),
                balance.prettierToText(
                  withSymbol: true,
                  withoutDecimal: true,
                  style: theme.textTheme.headlineSmall!.copyWith(color: color),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ResumeAcc {
  double expense;
  double income;
  double transfer;

  ResumeAcc({this.expense = 0.0, this.income = 0.0, this.transfer = 0.0});

  double byType(TransactionType type, {bool round = false}) {
    double amount;
    if (type == TransactionType.expense) {
      amount = expense.abs();
    } else if (type == TransactionType.income) {
      amount = income;
    } else {
      amount = transfer;
    }
    return round ? amount.roundToDouble() : amount;
  }
}

class TotalBalance extends StatelessWidget {
  final List<Transaction> transactions;
  final Map<TransactionType, bool> selectedTypes;
  const TotalBalance({required this.transactions, required this.selectedTypes, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ResumeAcc resume = transactions.fold(ResumeAcc(), (r, t) {
      if (t.type == TransactionType.income) {
        r.income += t.balanceFixed;
      } else if (t.type == TransactionType.expense) {
        r.expense += t.balanceFixed;
      } else if (t.type == TransactionType.transfer) {
        r.transfer += t.balanceFixed;
      }
      return r;
    });

    final items = TransactionType.values.fold<List<Widget>>([], (acc, type) {
      if (selectedTypes[type] == true) {
        acc.add(Expanded(
          child: Card(
            margin: const EdgeInsets.all(5),
            color: theme.colorScheme.background,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(radiusApp)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                children: [
                  Text(
                    Convert.capitalize(type.toShortString()).i18n,
                    style: theme.textTheme.bodyMedium!.copyWith(color: theme.hintColor),
                  ),
                  resume.byType(type, round: true).prettierToText(withSymbol: true, style: theme.textTheme.titleLarge)
                ],
              ),
            ),
          ),
        ));
      }
      return acc;
    }).toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(radiusApp)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: items),
      ),
    );
  }
}
