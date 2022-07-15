import 'package:budget/common/color_constants.dart';
import 'package:budget/model/budget.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

DateTime now = DateTime.now();

class SpendGraphic extends StatelessWidget {
  late List<FlSpot> spots;

  final gradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [blue.withOpacity(0.0), blue.withOpacity(0.6)],
  );

  SpendGraphic(List<Budget> budgets, {Key? key}) : super(key: key) {
    // final frameDate = now.subtract(const Duration(days: 30));

    // final frameBudgets = budgets.where((b) => b.date.isAfter(frameDate));
    double accAmount = 0.0;

    spots = List.generate(30, (index) {
      // frameBudgets.fold(0, (prev, element) => prev + element)
      return FlSpot(index.toDouble(), accAmount);
    });
  }

  getBottomTitles() {
    return SideTitles(
      showTitles: true,
      interval: 3,
      getTitlesWidget: (double axis, TitleMeta titleMeta) {
        return Text(now.subtract(Duration(days: axis.toInt())).day.toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      width: double.infinity,
      height: 200,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              axisNameWidget: const Text('Dias'),
              sideTitles: getBottomTitles(),
            ),
            topTitles: AxisTitles(axisNameWidget: const Text(''), sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              dotData: FlDotData(show: false),
              color: blue,
              belowBarData: BarAreaData(show: true, gradient: gradient),
            )
          ],
        ),
      ),
    );
  }
}
