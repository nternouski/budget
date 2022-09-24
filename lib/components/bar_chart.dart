import 'package:budget/common/styles.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:budget/common/convert.dart';
import 'package:budget/model/transaction.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class BarChartGroup {
  DateTime y;
  BarChartGroupData data;
  BarChartGroup({required this.y, required this.data}) : super();
}

class BarChartWidget extends StatefulWidget {
  final List<Transaction> transactions;
  final DateTime frameDate;
  const BarChartWidget({Key? key, required this.transactions, required this.frameDate}) : super(key: key);

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

    return AspectRatio(
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
    var format = DateTime.now().month != date.month ? DateFormat.ABBR_MONTH_DAY : 'd';
    var text = value.toInt() % 2 != 0 ? '' : DateFormat(format).format(date);
    return SideTitleWidget(axisSide: meta.axisSide, space: 5, child: Text(text));
  }
}
