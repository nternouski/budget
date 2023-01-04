import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../common/theme.dart';
import '../server/database/transaction_rx.dart';
import '../model/wallet.dart';
import '../model/user.dart';
import '../common/convert.dart';
import '../model/transaction.dart';

DateTime now = DateTime.now();

class Balance {
  late String key;
  late DateTime date;
  late double balance;

  Balance(this.date, this.balance, this.key);
}

class SpendGraphic extends StatefulWidget {
  final User user;
  final int frameRange;

  const SpendGraphic({Key? key, required this.frameRange, required this.user}) : super(key: key);

  @override
  State<SpendGraphic> createState() => _SpendGraphicState();
}

class _SpendGraphicState extends State<SpendGraphic> {
  late List<FlSpot> spots;

  double maxBalance = 0;
  double minBalance = 0.0;
  double? firstBalanceOfFrame;
  List<Balance> frame = [];

  final _formatKey = DateFormat('y/M/d');

  List<Balance> calcFrame(List<Transaction> transactions, double initialBalance, DateTime frameDate) {
    var balancedDay = transactions.fold<Map<String, Balance>>({}, (acc, t) {
      if (t.date.isBefore(frameDate)) return acc;

      var key = _formatKey.format(t.date);
      if (acc.containsKey(key)) {
        acc[key]?.balance += t.type == TransactionType.transfer ? t.fee : t.balanceFixed;
      } else {
        acc.addAll({key: Balance(t.date, t.balanceFixed, key)});
      }
      return acc;
    });

    for (var pivote = widget.frameRange; pivote >= 0; pivote--) {
      var date = now.subtract(Duration(days: pivote));
      var key = _formatKey.format(date);
      var lastFrame = frame.isEmpty ? Balance(date, initialBalance, key) : frame.last;
      var balance = balancedDay[key];
      if (balance != null) {
        balance.balance += lastFrame.balance;
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
      interval: widget.frameRange / 5,
      getTitlesWidget: (double axis, TitleMeta titleMeta) {
        DateTime date = frame[axis.toInt()].date;
        var format = now.month != date.month ? DateFormat.ABBR_MONTH_DAY : 'd';
        return Text(DateFormat(format).format(date), style: const TextStyle(height: 2));
      },
      reservedSize: 25,
    );
  }

  getLeftTitles() {
    return SideTitles(
      showTitles: true,
      interval: maxBalance / 2 + 1,
      reservedSize: 25,
      getTitlesWidget: (double axis, TitleMeta titleMeta) => Text(Convert.roundMoney(axis + minBalance)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime frameDate = now.subtract(Duration(days: widget.frameRange));

    return StreamBuilder<List<Transaction>>(
      stream: transactionRx.getTransactions(widget.user.id),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState.name == 'waiting') {
          return SizedBox(
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Progress.getLoadingProgress(context: context)],
            ),
          );
        }
        List<Transaction> transactions = List.from(snapshot.data ?? []);
        List<Wallet> wallets = List.from(Provider.of<List<Wallet>>(context));

        // Calc Initial value of graph
        double total = wallets.fold<double>(
          widget.user.initialAmount,
          (acc, w) => acc + w.initialAmount + w.balanceFixed,
        );
        firstBalanceOfFrame = transactions
            .where((t) => t.date.isAfter(frameDate))
            .fold<double>(total, (prev, element) => prev - element.balanceFixed);
        frame = [];

        return getGraph(context, frameDate, transactions);
      },
    );
  }

  Widget getGraph(BuildContext context, DateTime frameDate, List<Transaction> transactions) {
    transactions.sort((a, b) => b.date.compareTo(a.date));
    frame = calcFrame(transactions, firstBalanceOfFrame ?? 0, frameDate);
    spots = List.generate(widget.frameRange + 1, (index) {
      var balance = frame[index].balance;
      if (balance < minBalance) minBalance = balance;
      if (balance > maxBalance) maxBalance = balance;
      return FlSpot(index.toDouble(), balance);
    });

    final color = Theme.of(context).colorScheme.primary;
    final gradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [color.withOpacity(0.0), color.withOpacity(0.6)],
    );

    return Container(
      padding: const EdgeInsets.all(0),
      width: double.infinity,
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          gridData: FlGridData(drawVerticalLine: false, horizontalInterval: maxBalance / 2 + 1),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: getBottomTitles()),
            topTitles: AxisTitles(axisNameWidget: const Text(''), sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(axisNameWidget: const Text(''), axisNameSize: 4, sideTitles: getLeftTitles()),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (value) => value.map((e) {
                return LineTooltipItem('Balance: \$ ${e.y.toInt()}', const TextStyle());
              }).toList(),
              tooltipBgColor: color.withOpacity(0.5),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              preventCurveOverShooting: true,
              curveSmoothness: 0.7,
              dotData: FlDotData(show: false),
              color: color,
              belowBarData: BarAreaData(show: true, gradient: gradient),
            )
          ],
        ),
      ),
    );
  }
}
