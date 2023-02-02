import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../i18n/index.dart';
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

    var colorBalance = theme.textTheme.titleMedium!.copyWith(
      color: balancePrediction.isNegative ? theme.colorScheme.error : theme.primaryColor,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 30, right: 30),
      child: Card(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(radiusApp)),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(children: [
            Text('Expense Simulation'.i18n, style: theme.textTheme.titleMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Balance: ', style: theme.textTheme.titleMedium),
                Text(balancePrediction.prettier(withSymbol: true), style: colorBalance)
              ],
            ),
          ]),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 30, right: 30),
      child: Card(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(radiusApp)),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                balance.isNegative ? Icons.keyboard_double_arrow_down_rounded : Icons.keyboard_double_arrow_up_rounded,
                size: 45,
                color: balance.isNegative ? theme.colorScheme.error : theme.primaryColor,
              ),
              Column(children: [
                Text(
                  'In the last %d months'.plural(maxPeriodBalance),
                  style: theme.textTheme.titleMedium,
                ),
                Text(balance.prettier(withSymbol: true), style: theme.textTheme.titleLarge)
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
