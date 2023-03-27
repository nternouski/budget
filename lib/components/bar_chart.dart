import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../components/spend_graphic.dart';
import '../model/currency.dart';
import '../model/transaction.dart';

class BarChartGroup {
  DateTime y;
  BarChartGroupData data;
  BarChartGroup({required this.y, required this.data}) : super();
}

class BarChartWidget extends StatefulWidget {
  final List<Transaction> transactions;
  final DateTime frameDate;
  final int frameWindow;

  const BarChartWidget({
    Key? key,
    required this.transactions,
    required this.frameDate,
    required this.frameWindow,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => BarChartWidgetState();
}

class BarChartWidgetState extends State<BarChartWidget> {
  List<BarChartGroup> rawBarGroups = [];
  double maxBalance = 0;

  bool showVerticalLabel = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    showVerticalLabel = nowZero.difference(widget.frameDate).inDays > 30;

    int index = 0;
    rawBarGroups = [];
    maxBalance = 0;
    final step = Duration(days: widget.frameWindow);
    final frameWindowDate = Duration(days: widget.frameWindow, microseconds: -1);
    for (var time = widget.frameDate; time.isBefore(nowZero); time = time.add(step)) {
      // By each type get the the amount of money and add as bar.
      final rodStackItems = TransactionType.values.fold<List<BarChartRodStackItem>>([], (acc, type) {
        double values = getBalanceOf(widget.transactions, type, time, time.add(frameWindowDate));
        if (values > maxBalance) maxBalance = values;
        acc.add(BarChartRodStackItem(0, values, colorsTypeTransaction[type]!));
        return acc;
      }).toList();

      rawBarGroups.add(BarChartGroup(
        y: time,
        data: BarChartGroupData(
          barsSpace: 0,
          x: index++,
          barRods: rodStackItems
              .map((item) => BarChartRodData(
                    toY: item.toY,
                    rodStackItems: [item],
                    width: 7,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [item.color, item.color.withAlpha(100)],
                    ),
                  ))
              .toList(),
        ),
      ));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        AspectRatio(
          aspectRatio: 1.4,
          child: Padding(
            padding: const EdgeInsets.only(top: 15),
            child: BarChart(
              BarChartData(
                maxY: maxBalance,
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: _bottomTitles(theme, step)),
                  leftTitles:
                      AxisTitles(axisNameWidget: const Text(''), axisNameSize: 4, sideTitles: _leftTitles(theme)),
                ),
                borderData: FlBorderData(show: false),
                barTouchData: getTooltip(theme),
                barGroups: rawBarGroups.map((g) => g.data).toList(),
                gridData: FlGridData(drawVerticalLine: false, horizontalInterval: maxBalance / 3 + 1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  getTooltip(ThemeData theme) {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
          tooltipPadding: const EdgeInsets.only(top: 8, left: 8, right: 8),
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          tooltipBgColor: theme.dialogBackgroundColor,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String amount = rod.rodStackItems[0].toY.prettier(withSymbol: true);
            Color color = rod.rodStackItems[0].color;
            return BarTooltipItem(
              amount,
              CurrencyPrettier.getFont(theme.textTheme.bodyLarge!.copyWith(color: color)),
            );
          }),
    );
  }

  double getBalanceOf(List<Transaction> transactions, TransactionType type, DateTime after, DateTime before) {
    return transactions.fold<double>(0.0, (acc, t) {
      final matchDate = t.date.isAtSameMomentAs(after) || (t.date.isAfter(after) && t.date.isBefore(before));
      return t.type == type && matchDate ? acc + t.balanceFixed.abs() : acc;
    });
  }

  _leftTitles(ThemeData theme) {
    return SideTitles(
      showTitles: true,
      interval: maxBalance / 3 + 1,
      reservedSize: 35,
      getTitlesWidget: (double axis, TitleMeta titleMeta) {
        if (axis == 0.0) {
          return const Text('');
        } else {
          return axis.prettierToText(
            withSymbol: false,
            simplify: true,
            style: theme.textTheme.bodyLarge,
          );
        }
      },
    );
  }

  _bottomTitles(ThemeData theme, Duration step) {
    final style = theme.textTheme.labelSmall;
    return SideTitles(
      showTitles: true,
      getTitlesWidget: (double value, TitleMeta meta) {
        DateTime date = rawBarGroups[value.toInt()].y;
        DateTime until = date.add(Duration(days: step.inDays - 1));
        if (showVerticalLabel) {
          return SideTitleWidget(
            axisSide: AxisSide.right,
            space: 15,
            angle: 1.57,
            child: Text('${date.day} to ${until.day}', style: style),
          );
        } else {
          return SideTitleWidget(
            axisSide: meta.axisSide,
            space: 2,
            child: Text('${date.day} to ${until.day}', style: style),
          );
        }
      },
      reservedSize: showVerticalLabel ? 40 : 15,
    );
  }
}
