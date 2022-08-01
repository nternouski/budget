import 'package:budget/common/transform.dart';
import 'package:budget/server/model_rx.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../common/color_constants.dart';
import '../model/transaction.dart';

DateTime now = DateTime.now();

class Balance {
  late String key;
  late DateTime date;
  late double balance;

  Balance(this.date, this.balance, this.key);
}

class SpendGraphic extends StatefulWidget {
  List<Transaction> transactions;

  static const int _frameRange = 30;
  SpendGraphic(this.transactions, {Key? key}) : super(key: key) {}

  @override
  State<SpendGraphic> createState() => _SpendGraphicState();
}

class _SpendGraphicState extends State<SpendGraphic> {
  late List<FlSpot> spots;

  late double maxBalance = 0;
  double? firstBalanceOfFrame;
  List<Balance> frame = [];

  final _gradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [blue.withOpacity(0.0), blue.withOpacity(0.6)],
  );

  final _formatKey = DateFormat('y/M/d');

  final DateTime _frameDate = now.subtract(const Duration(days: SpendGraphic._frameRange));

  List<Balance> calcFrame(List<Transaction> transaction, double initialBalance) {
    var balancedDay = transaction.fold<Map<String, Balance>>({}, (acc, t) {
      if (t.date.isBefore(_frameDate)) return acc;

      var key = _formatKey.format(t.date);
      if (acc.containsKey(key)) {
        acc[key]?.balance += t.balance;
      } else {
        acc.addAll({key: Balance(t.date, t.balance, key)});
      }
      return acc;
    });

    for (var pivote = SpendGraphic._frameRange; pivote > 0; pivote--) {
      var date = now.subtract(Duration(days: pivote));
      var key = _formatKey.format(date);
      var lastFrame = frame.isEmpty ? Balance(date, initialBalance, key) : frame.last;
      var balance = balancedDay[key];
      if (balance != null) {
        balance.balance += lastFrame.balance;
        if (balance.balance > maxBalance) maxBalance = balance.balance;
        frame.add(balance);
      } else {
        frame.add(Balance(date, lastFrame.balance, key));
      }
    }
    return frame;
  }

  getBottomTitles() {
    return SideTitles(
      showTitles: true,
      interval: 5,
      getTitlesWidget: (double axis, TitleMeta titleMeta) => Text(frame[axis.toInt()].date.day.toString()),
    );
  }

  getLeftTitles() {
    return SideTitles(
      showTitles: true,
      interval: maxBalance / 2 + 1,
      reservedSize: 25,
      getTitlesWidget: (double axis, TitleMeta titleMeta) => Text(Convert.roundMoney(axis)),
    );
  }

  void updateFirstBalanceFrame() async {
    // FIXME: Hacerlo mas eficiente
    if (firstBalanceOfFrame == null) {
      double balance = await transactionRx.getBalanceAt(_frameDate);
      setState(() {
        firstBalanceOfFrame = balance;
        frame = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    updateFirstBalanceFrame();
    widget.transactions.sort((a, b) => b.date.compareTo(a.date));
    frame = calcFrame(widget.transactions, firstBalanceOfFrame ?? 0);
    spots = List.generate(SpendGraphic._frameRange, (index) => FlSpot(index.toDouble(), frame[index].balance));

    return Container(
      padding: const EdgeInsets.all(0),
      width: double.infinity,
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          gridData: FlGridData(drawVerticalLine: false, horizontalInterval: maxBalance / 2 + 1),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(axisNameWidget: const Text('Dias'), sideTitles: getBottomTitles()),
            topTitles: AxisTitles(axisNameWidget: const Text(''), sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(axisNameWidget: const Text(''), sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(axisNameWidget: const Text(''), sideTitles: getLeftTitles()),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              preventCurveOverShooting: true,
              curveSmoothness: 0.7,
              dotData: FlDotData(show: false),
              color: blue,
              belowBarData: BarAreaData(show: true, gradient: _gradient),
            )
          ],
        ),
      ),
    );
  }
}
