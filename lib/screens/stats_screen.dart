import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/category.dart';
import '../components/icon_circle.dart';
import '../common/period_stats.dart';
import '../common/preference.dart';
import '../common/styles.dart';
import '../components/spend_graphic.dart';
import '../model/transaction.dart';

class PieCategory {
  final Category category;
  final double porcentaje;

  PieCategory(this.category, this.porcentaje);
}

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  StatsScreenState createState() => StatsScreenState();
}

class StatsScreenState extends State<StatsScreen> {
  Preferences preferences = Preferences();
  int touchedIndex = 0;

  StatsScreenState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<Transaction> transactions = Provider.of<List<Transaction>>(context);

    return Scaffold(
      appBar: AppBar(
        titleTextStyle: theme.textTheme.titleLarge,
        leading: getBackButton(context),
        title: const Text('Stats'),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          ValueListenableBuilder<PeriodStats>(
            valueListenable: periods.selected,
            builder: (context, periodStats, child) => getBody(context, theme, transactions, periodStats),
          )
        ],
      ),
    );
  }

  Widget getBody(BuildContext context, ThemeData theme, List<Transaction> transactions, PeriodStats periodStats) {
    List<Category> categories = Provider.of<List<Category>>(context);
    final DateTime frameDate = now.subtract(Duration(days: periodStats.days));
    transactions = transactions.where((t) => t.date.isAfter(frameDate)).toList();

    final double total = transactions.fold<double>(0.0, (prev, t) => prev + t.balanceFixed.abs());

    List<PieCategory> pie = categories.map((c) {
      double acc = transactions.fold<double>(0.0, (p, t) => t.categoryId == c.id ? p + t.balanceFixed.abs() : p);
      return PieCategory(c, total == 0 ? 0 : (acc * 100) / total);
    }).toList();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 10, left: 20, right: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: pie.map((p) => _Indicator(text: p.category.name, color: p.category.color)).toList(),
              ),
            ),
            AspectRatio(
              aspectRatio: 1.3,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() => touchedIndex = pieTouchResponse?.touchedSection?.touchedSectionIndex ?? -1);
                  }),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 30,
                  sections: showingSections(pie),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections(List<PieCategory> pie) {
    final List fixedList = Iterable<int>.generate(pie.length).toList();

    return fixedList.map((index) {
      Category category = pie[index].category;
      double porcentaje = pie[index].porcentaje;

      final isTouched = index == touchedIndex;
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

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final double size = 16;

  const _Indicator({Key? key, required this.color, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
      ],
    );
  }
}
