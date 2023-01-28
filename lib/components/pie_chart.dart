import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../i18n/index.dart';
import '../common/period_stats.dart';
import '../common/styles.dart';
import '../components/daily_item.dart';
import '../components/icon_circle.dart';
import '../model/category.dart';
import '../model/transaction.dart';
import '../model/user.dart';
import '../model/currency.dart';
import '../screens/stats_screen.dart';

class PieCategory extends CategorySelected {
  final double porcentaje;

  PieCategory(super.category, this.porcentaje, super.isSelected) : super();
}

class StatsPieChart extends StatefulWidget {
  final List<CategorySelected> categoriesSelected;
  final List<Transaction> transactions;
  final double total;
  final PeriodStats periodStats;
  const StatsPieChart({
    required this.categoriesSelected,
    required this.transactions,
    required this.total,
    required this.periodStats,
    Key? key,
  }) : super(key: key);

  @override
  StatsPieChartState createState() => StatsPieChartState();
}

class StatsPieChartState extends State<StatsPieChart> {
  PieCategory? pieSliceSelected;

  StatsPieChartState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<PieCategory> pie = widget.categoriesSelected.fold<List<PieCategory>>([], (acc, item) {
      if (!item.isSelected || item.totalAmount == 0) return acc;
      return [
        ...acc,
        PieCategory(
          item.category,
          widget.total == 0 ? 0 : (item.totalAmount * 100) / widget.total,
          item.isSelected,
        )
      ];
    }).toList();

    List<Transaction> transactionSelected =
        widget.transactions.where((t) => t.categoryId == pieSliceSelected?.category.id).toList();
    User user = Provider.of<User>(context);
    double totalSelected = transactionSelected.fold(0.0, (acc, t) => t.balanceFixed + acc);
    String symbol = user.defaultCurrency.symbol;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AspectRatio(
            aspectRatio: 1.2,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    int touchedIndex = pieTouchResponse?.touchedSection?.touchedSectionIndex ?? -1;
                    if (!event.isInterestedForInteractions || touchedIndex == -1) return;
                    pieSliceSelected = pie[touchedIndex];
                  });
                }),
                borderData: FlBorderData(show: false),
                sectionsSpace: 0,
                centerSpaceRadius: 30,
                sections: showingSections(pie),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('${'Category'.i18n} ${pieSliceSelected?.category.name}', style: theme.textTheme.titleLarge)
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [Text('${'Currency'.i18n} $symbol ${totalSelected.prettier(withSymbol: true)}')]),
              ),
              ...List.generate(
                transactionSelected.length,
                (index) =>
                    DailyItem(transaction: transactionSelected[index], key: Key(Random().nextDouble().toString())),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections(List<PieCategory> pie) {
    final List fixedList = Iterable<int>.generate(pie.length).toList();

    return fixedList.map((index) {
      Category category = pie[index].category;
      double porcentaje = pie[index].porcentaje;

      final isTouched = pieSliceSelected?.category.id == category.id;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 90.0 : 80.0;
      final widgetSize = isTouched ? 52.0 : 42.0;

      return PieChartSectionData(
        color: category.color,
        value: porcentaje,
        title: porcentaje > 3 ? '${porcentaje.round()}%' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: TextColor.getContrastOf(category.color),
        ),
        badgeWidget: porcentaje > 5 ? _Badge(category.icon, size: widgetSize, borderColor: category.color) : null,
        badgePositionPercentageOffset: 1,
      );
    }).toList();
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color borderColor;

  const _Badge(this.icon, {Key? key, required this.size, required this.borderColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: TextColor.getContrastOf(theme.colorScheme.onBackground).withOpacity(.8),
            blurRadius: 4,
          ),
        ],
      ),
      child: IconCircle(icon: icon, color: borderColor),
    );
  }
}
