import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../i18n/index.dart';
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
    final theme = Theme.of(context);
    final predictionOnStats = Provider.of<PredictionOnStatsNotifier>(context);
    final temp = Provider.of<List<ExpensePrediction>>(context);

    if (!predictionOnStats.enable || temp.isEmpty) return const SizedBox();

    List<CurrencyRate> currencyRates = Provider.of<List<CurrencyRate>>(context);
    List<Currency> currencies = Provider.of<List<Currency>>(context);
    User user = Provider.of<User>(context);
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

    var color = balancePrediction.isNegative ? theme.colorScheme.error : theme.primaryColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 15, left: 30, right: 30),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(radiusApp)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Balance ${'Expense Simulation'.i18n}',
              style: theme.textTheme.bodyLarge!.copyWith(color: theme.hintColor),
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
                Text(
                  balancePrediction.prettier(withSymbol: true),
                  style: theme.textTheme.headlineSmall!.copyWith(color: color),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ],
        ),
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

    int maxPeriodBalance = (TransactionRx.windowFetchTransactions.inDays / 30).floor();
    double balance = transactions.fold(0.0, (acc, t) => acc + t.getBalanceFromType());
    Color color = balance.isNegative ? theme.colorScheme.error : theme.primaryColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 15, left: 30, right: 30),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(radiusApp)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'In the last %d months'.plural(maxPeriodBalance),
              style: theme.textTheme.bodyLarge!.copyWith(color: theme.hintColor),
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
                Text(balance.prettier(withSymbol: true), style: theme.textTheme.headlineSmall!.copyWith(color: color))
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

  double byType(TransactionType type) {
    if (type == TransactionType.expense) {
      return expense;
    } else if (type == TransactionType.income) {
      return income;
    } else {
      return transfer;
    }
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

    return Card(
      margin: const EdgeInsets.only(left: 30, right: 30),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(radiusApp)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Total', style: theme.textTheme.bodyLarge!.copyWith(color: theme.hintColor)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: TransactionType.values.fold<List<Widget>>([], (acc, type) {
                if (selectedTypes[type] == true) {
                  acc.add(Column(
                    children: [
                      Text(Convert.capitalize(type.toShortString()).i18n),
                      Text(resume.byType(type).prettier(withSymbol: true), style: theme.textTheme.titleMedium)
                    ],
                  ));
                }
                return acc;
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
