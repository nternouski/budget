import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../i18n/index.dart';
import '../components/spend_graphic.dart';
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
  final int frameWindow;

  const BarChartWidget({
    Key? key,
    required this.transactions,
    required this.selectedTypes,
    required this.frameDate,
    required this.frameWindow,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => BarChartWidgetState();
}

class BarChartWidgetState extends State<BarChartWidget> {
  final double width = 7;
  List<BarChartGroup> rawBarGroups = [];
  double maxBalance = 0;

  TextStyle? labelTextStyle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    labelTextStyle = theme.textTheme.labelMedium;

    int index = 0;
    rawBarGroups = [];
    maxBalance = 0;
    final step = Duration(days: widget.frameWindow);
    final frameWindowDate = Duration(days: widget.frameWindow, microseconds: -1);
    for (var time = widget.frameDate; time.isBefore(nowZero); time = time.add(step)) {
      final rodStackItems = TransactionType.values.fold<List<BarChartRodStackItem>>([], (acc, type) {
        double values = getBalanceOf(widget.transactions, type, time, time.add(frameWindowDate));
        if (values > maxBalance) maxBalance = values;
        acc.add(BarChartRodStackItem(0, values, colorsTypeTransaction[type]!));
        return acc;
      }).toList();

      rawBarGroups.add(BarChartGroup(
        y: time,
        data: BarChartGroupData(
            barsSpace: 3,
            x: index++,
            barRods: rodStackItems
                .map((item) => BarChartRodData(toY: item.toY, rodStackItems: [item], width: width, color: item.color))
                .toList()),
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
                  bottomTitles: AxisTitles(sideTitles: bottomTitles()),
                  leftTitles: AxisTitles(
                    axisNameWidget: const Text(''),
                    axisNameSize: 4,
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxBalance / 3 + 1,
                      reservedSize: 22,
                      getTitlesWidget: (double axis, TitleMeta titleMeta) => Text(
                        axis == 0.0 ? '' : Convert.roundMoney(axis),
                        style: labelTextStyle,
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barTouchData: getTooltip(theme),
                barGroups: rawBarGroups.map((g) => g.data).toList(),
                gridData: FlGridData(drawVerticalLine: false, horizontalInterval: maxBalance / 3 + 1),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.selectedTypes[TransactionType.income] == true)
              Text('${'Total Income'.i18n}: ${resume.income.prettier(withSymbol: true)}',
                  style: theme.textTheme.titleMedium),
            if (widget.selectedTypes[TransactionType.expense] == true)
              Text('${'Total Expense'.i18n}: ${resume.expense.prettier(withSymbol: true)}',
                  style: theme.textTheme.titleMedium),
            if (widget.selectedTypes[TransactionType.transfer] == true)
              Text('${'Total Transfer'.i18n}: ${resume.transfer.prettier(withSymbol: true)}',
                  style: theme.textTheme.titleMedium)
          ],
        ),
      ],
    );
  }

  getTooltip(ThemeData theme) {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: theme.dialogBackgroundColor,
        getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
          '',
          theme.textTheme.bodyLarge!,
          children: rod.rodStackItems.fold<List<TextSpan>>([], (acc, item) {
            if (item.toY.compareTo(0.0) > 0) {
              acc.add(TextSpan(text: item.toY.prettier(withSymbol: true), style: TextStyle(color: item.color)));
            }
            return acc;
          }),
        ),
      ),
    );
  }

  double getBalanceOf(List<Transaction> transactions, TransactionType type, DateTime after, DateTime before) {
    return transactions.fold<double>(0.0, (acc, t) {
      final matchDate = t.date.isAtSameMomentAs(after) || (t.date.isAfter(after) && t.date.isBefore(before));
      return t.type == type && matchDate ? acc + t.balanceFixed.abs() : acc;
    });
  }

  bottomTitles() {
    return SideTitles(
      showTitles: true,
      getTitlesWidget: (double value, TitleMeta meta) {
        DateTime date = rawBarGroups[value.toInt()].y;
        if (nowZero.difference(widget.frameDate).inDays < 30) {
          final format = nowZero.month != date.month ? 'dMMM' : 'd';
          return SideTitleWidget(
            axisSide: meta.axisSide,
            space: 5,
            child: Text(DateFormat(format).format(date), style: labelTextStyle),
          );
        } else {
          return SideTitleWidget(
            axisSide: AxisSide.right,
            space: 15,
            angle: 1.57,
            child: Text(DateFormat('d MMM').format(date), style: labelTextStyle),
          );
        }
      },
      reservedSize: 30,
    );
  }
}
