import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../i18n/index.dart';
import '../common/classes.dart';
import '../common/styles.dart';
import '../components/interaction_border.dart';
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
  final DateTime frameDate;
  const StatsPieChart({
    required this.categoriesSelected,
    required this.transactions,
    required this.total,
    required this.frameDate,
    Key? key,
  }) : super(key: key);

  @override
  StatsPieChartState createState() => StatsPieChartState();
}

class StatsPieChartState extends State<StatsPieChart> {
  DateTimeRange? range;
  final dateFormat = DateFormat(DateFormat.ABBR_MONTH_DAY);

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

    if (range == null) _setRange(start: widget.frameDate);

    List<Transaction> transactionSelected = widget.transactions
        .where(
          (t) =>
              t.categoryId == pieSliceSelected?.category.id &&
              t.date.isAfter(range!.start) &&
              t.date.isBefore(range!.end),
        )
        .toList();

    double totalSelected = transactionSelected.fold(0.0, (acc, t) => t.balanceFixed + acc);

    User user = Provider.of<User>(context);
    String symbol = user.defaultCurrency.symbol;

    String title = 'Select Category'.i18n;
    if (pieSliceSelected != null) {
      title = '${'Category'.i18n} ${pieSliceSelected?.category.name}';
    }

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
                sections: showingSections(theme, pie),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 100),
          child: Column(
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 10),
              if (user.superUser) _getRangeFilter(theme),
              Padding(
                padding: const EdgeInsets.only(right: 10, top: 10),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('${'Currency'.i18n} $symbol '),
                  totalSelected.prettierToText(withSymbol: true),
                ]),
              ),
              ...List.generate(
                transactionSelected.length,
                (index) => DailyItem(
                  transaction: transactionSelected[index],
                  key: Key(transactionSelected[index].id.toString()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections(ThemeData theme, List<PieCategory> pie) {
    final List fixedList = Iterable<int>.generate(pie.length).toList();

    return fixedList.map((index) {
      Category category = pie[index].category;
      double porcentaje = pie[index].porcentaje;

      final isTouched = pieSliceSelected?.category.id == category.id;
      final radius = isTouched ? 90.0 : 80.0;
      final widgetSize = isTouched ? 52.0 : 42.0;

      final font = (isTouched ? theme.textTheme.titleLarge : theme.textTheme.bodyLarge)
          ?.copyWith(color: getContrastOf(category.color));

      return PieChartSectionData(
        color: category.color,
        value: porcentaje,
        title: porcentaje > 3 ? '${porcentaje.round()}%' : '',
        radius: radius,
        titleStyle: font,
        badgeWidget: porcentaje > 5 ? _Badge(category.icon, size: widgetSize, borderColor: category.color) : null,
        badgePositionPercentageOffset: 1,
      );
    }).toList();
  }

  _getRangeFilter(ThemeData theme) {
    return AppInteractionBorder(
      margin: const EdgeInsets.all(10),
      onTap: () async {
        // Below line stops keyboard from appearing
        FocusScope.of(context).requestFocus(FocusNode());
        // Show Date Picker Here
        final DateTimeRange? picked = await showDateRangePicker(
          context: context,
          initialDateRange: range,
          firstDate: widget.frameDate,
          lastDate: DateTime.now(),
        );
        if (picked != null && picked != range) setState(() => _setRange(start: picked.start, end: picked.end));
      },
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.edit_calendar_rounded),
        const SizedBox(width: 10),
        Text(
          '${dateFormat.format(range!.start)} - ${dateFormat.format(range!.end)}',
          style: theme.textTheme.titleMedium,
        ),
      ]),
    );
  }

  void _setRange({required DateTime start, DateTime? end}) {
    range = DateTimeRange(
      start: start.copyWith(toZeroHours: true),
      end: (end ?? DateTime.now()).copyWith(toLastMomentDay: true),
    );
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
            color: getContrastOf(theme.colorScheme.onBackground).withOpacity(.8),
            blurRadius: 4,
          ),
        ],
      ),
      child: IconCircle(icon: icon, color: borderColor, size: size - 10),
    );
  }
}
