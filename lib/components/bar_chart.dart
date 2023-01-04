import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../model/currency.dart';
import '../common/convert.dart';
import '../model/transaction.dart';

class BarChartGroup {
  DateTime y;
  BarChartGroupData data;
  BarChartGroup({required this.y, required this.data}) : super();
}

class ResumeAcc {
  double expense;
  double income;
  double transfer;

  ResumeAcc({this.expense = 0.0, this.income = 0.0, this.transfer = 0.0});
}

class BarChartWidget extends StatefulWidget {
  final List<Transaction> transactions;
  final DateTime frameDate;
  final Map<TransactionType, bool> selectedTypes;
  const BarChartWidget({Key? key, required this.transactions, required this.selectedTypes, required this.frameDate})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => BarChartWidgetState();
}

class BarChartWidgetState extends State<BarChartWidget> {
  final double width = 7;
  final barDuration = const Duration(days: 7);

  int lengthGroup = 0;
  List<BarChartGroup> rawBarGroups = [];
  double maxBalance = 0;
  int touchedGroupIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    int index = 0;
    rawBarGroups = [];
    maxBalance = 0;
    for (var time = widget.frameDate; time.isBefore(DateTime.now()); time = time.add(barDuration)) {
      final rodStackItems = TransactionType.values.fold<List<BarChartRodStackItem>>([], (acc, type) {
        double values = getBalanceOf(widget.transactions, type, time);
        double prevValue = acc.isEmpty ? 0 : acc.last.toY;
        double total = prevValue + values;

        if (total > maxBalance) maxBalance = total;
        acc.add(BarChartRodStackItem(prevValue, total, colorsTypeTransaction[type]!));
        return acc;
      }).toList();

      rawBarGroups.add(BarChartGroup(
        y: time,
        data: BarChartGroupData(
          barsSpace: 4,
          x: index++,
          barRods: [
            BarChartRodData(
              toY: rodStackItems.last.toY,
              rodStackItems: rodStackItems,
              width: width,
              color: rodStackItems.lastWhereOrNull((i) => i.fromY != i.toY)?.color,
            )
          ],
        ),
      ));
    }

    ResumeAcc resume = widget.transactions.fold(ResumeAcc(), (r, t) {
      if (t.type == TransactionType.income) {
        r.income += t.balanceFixed;
      } else if (t.type == TransactionType.expense) {
        r.expense += t.balanceFixed;
      } else if (t.type == TransactionType.transfer) {
        r.transfer += t.balanceFixed;
      }
      return r;
    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        AspectRatio(
          aspectRatio: 1.4,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: BarChart(
              BarChartData(
                maxY: maxBalance,
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, getTitlesWidget: bottomTitles, reservedSize: 30),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: const Text(''),
                    axisNameSize: 4,
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxBalance / 2 + 1,
                      reservedSize: 30,
                      getTitlesWidget: (double axis, TitleMeta titleMeta) => Text(Convert.roundMoney(axis + 0)),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: rawBarGroups.map((g) => g.data).toList(),
                gridData: FlGridData(show: false),
              ),
            ),
          ),
        ),
        const Text('1 bar 1 week'),
        const SizedBox(height: 20),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.selectedTypes[TransactionType.income] == true)
              Text('Total Income: \$${resume.income.prettier()}', style: theme.textTheme.titleMedium),
            if (widget.selectedTypes[TransactionType.expense] == true)
              Text('Total Expense: \$${resume.expense.prettier()}', style: theme.textTheme.titleMedium),
            if (widget.selectedTypes[TransactionType.transfer] == true)
              Text('Total Transfer: \$${resume.transfer.prettier()}', style: theme.textTheme.titleMedium)
          ],
        ),
      ],
    );
  }

  double getBalanceOf(List<Transaction> transactions, TransactionType type, DateTime time) {
    return transactions.fold<double>(0.0, (acc, t) {
      final match = t.type == type && t.date.isAfter(time) && t.date.isBefore(time.add(barDuration));
      return match ? acc + t.balanceFixed.abs() : acc;
    });
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    DateTime date = rawBarGroups[value.toInt()].y;
    var format = DateTime.now().month != date.month ? 'dMMM' : 'd';
    var text = value.toInt() % 2 != 0 ? '' : DateFormat(format).format(date);
    return SideTitleWidget(axisSide: meta.axisSide, space: 5, child: Text(text));
  }
}
