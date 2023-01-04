import 'dart:math';
import 'package:budget/common/convert.dart';
import 'package:budget/model/user.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/daily_item.dart';
import '../components/bar_chart.dart';
import '../components/icon_circle.dart';
import '../components/spend_graphic.dart';
import '../common/period_stats.dart';
import '../common/preference.dart';
import '../common/styles.dart';
import '../model/currency.dart';
import '../model/category.dart';
import '../model/transaction.dart';

class CategorySelected {
  final Category category;
  late double totalAmount;
  final bool isSelected;

  CategorySelected(this.category, this.isSelected, {this.totalAmount = 0});
}

class PieCategory extends CategorySelected {
  final double porcentaje;

  PieCategory(super.category, this.porcentaje, super.isSelected) : super();
}

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  StatsScreenState createState() => StatsScreenState();
}

class StatsScreenState extends State<StatsScreen> {
  Preferences preferences = Preferences();
  PieCategory? pieSliceSelected;
  List<String>? selectedCategories;
  Map<TransactionType, bool> selectedTypes = TransactionType.values.asMap().map((_, value) => MapEntry(value, true));

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
        body: ValueListenableBuilder<PeriodStats>(
          valueListenable: periods.selected,
          builder: (context, periodStats, child) {
            final DateTime frameDate = now.subtract(Duration(days: periodStats.days));
            List<Category> categories = Provider.of<List<Category>>(context);
            selectedCategories ??= categories.isEmpty ? null : categories.map((c) => c.id).toList();
            double total = 0;

            transactions = transactions
                .where((t) =>
                    t.date.isAfter(frameDate) &&
                    selectedCategories!.contains(t.categoryId) &&
                    selectedTypes[t.type] == true)
                .toList();

            List<CategorySelected> categoriesSelected = categories.map((c) {
              bool isSelected = selectedCategories != null && selectedCategories!.contains(c.id);
              double acc =
                  transactions.fold<double>(0.0, (p, t) => t.categoryId == c.id ? p + t.balanceFixed.abs() : p);
              total += isSelected ? acc : 0;
              return CategorySelected(c, isSelected, totalAmount: acc);
            }).toList();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(children: [
                      Text('Period: ${periodStats.humanize}', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: selectedTypes.entries
                            .map((e) => Padding(
                                  padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
                                  child: GestureDetector(
                                    onTap: () => setState(() => selectedTypes.update(e.key, (value) => !value)),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border:
                                            e.value ? Border.all(width: 2, color: colorsTypeTransaction[e.key]!) : null,
                                        borderRadius: categoryBorderRadius,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 10),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Container(
                                              width: 16,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle, color: colorsTypeTransaction[e.key]),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(Convert.capitalize(e.key.toShortString()))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 10),
                      Divider(color: theme.dividerColor, thickness: 2),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: categoriesSelected.map((p) {
                            return _Indicator(
                              category: p.category,
                              isSelected: p.isSelected,
                              onTap: (bool isSelected, String id) {
                                if (isSelected) {
                                  selectedCategories = [...(selectedCategories ?? []), id];
                                } else {
                                  selectedCategories = (selectedCategories ?? []).where((s) => s != id).toList();
                                }
                                setState(() {});
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ]),
                  ),
                ),
                SliverToBoxAdapter(
                  child: BarChartWidget(transactions: transactions, selectedTypes: selectedTypes, frameDate: frameDate),
                ),
                pieChart(context, theme, categoriesSelected, transactions, total, periodStats),
              ],
            );
          },
        ));
  }

  Widget pieChart(
    BuildContext context,
    ThemeData theme,
    List<CategorySelected> categoriesSelected,
    List<Transaction> transactions,
    double total,
    PeriodStats periodStats,
  ) {
    List<PieCategory> pie = categoriesSelected.fold<List<PieCategory>>([], (acc, item) {
      if (!item.isSelected || item.totalAmount == 0) return acc;
      return [...acc, PieCategory(item.category, total == 0 ? 0 : (item.totalAmount * 100) / total, item.isSelected)];
    }).toList();

    List<Transaction> transactionSelected =
        transactions.where((t) => t.categoryId == pieSliceSelected?.category.id).toList();
    User user = Provider.of<User>(context);
    double totalSelected = transactionSelected.fold(0.0, (acc, t) => t.balanceFixed + acc);
    String symbol = user.defaultCurrency.symbol;
    return SliverToBoxAdapter(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 10, left: 20, right: 20),
          child: AspectRatio(
            aspectRatio: 1.3,
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
          padding: const EdgeInsets.only(top: 15, bottom: 80),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text('Category ${pieSliceSelected?.category.name}', style: theme.textTheme.titleLarge)]),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [Text('Currency $symbol \$${totalSelected.prettier()}')]),
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
    ));
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

class _Indicator extends StatelessWidget {
  final Category category;
  final double size = 16;
  final bool isSelected;
  final Function(bool isSelected, String id) onTap;

  const _Indicator({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(!isSelected, category.id),
      child: Container(
        decoration: BoxDecoration(
          border: isSelected ? Border.all(width: 2, color: category.color) : null,
          borderRadius: categoryBorderRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(shape: BoxShape.circle, color: category.color),
              ),
              const SizedBox(width: 5),
              Text(category.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
            ],
          ),
        ),
      ),
    );
  }
}
