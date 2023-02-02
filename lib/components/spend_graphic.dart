import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../common/classes.dart';
import '../common/theme.dart';
import '../server/database/transaction_rx.dart';
import '../model/wallet.dart';
import '../model/user.dart';
import '../model/transaction.dart';

DateTime nowZero = DateTime.now().copyWith(toZeroHours: true);

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

  TextStyle? labelTextStyle;

  final _formatKey = DateFormat('y/M/d');

  List<Balance> calcFrame(List<Transaction> transactions, double initialBalance, DateTime frameDate) {
    var balancedDay = transactions.fold<Map<String, Balance>>({}, (acc, t) {
      if (t.date.isBefore(frameDate)) return acc;

      final key = _formatKey.format(t.date);
      if (acc.containsKey(key)) {
        acc[key]?.balance += t.getBalanceFromType();
      } else {
        acc.addAll({key: Balance(t.date, t.getBalanceFromType(), key)});
      }
      return acc;
    });

    for (var pivote = widget.frameRange; pivote >= 0; pivote--) {
      var date = nowZero.subtract(Duration(days: pivote));
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

  SideTitles _getTopTitles() {
    return SideTitles(
      showTitles: true,
      interval: widget.frameRange / 4,
      getTitlesWidget: (double axis, TitleMeta titleMeta) {
        return const SizedBox();
        // DateTime date = frame[axis.toInt()].date;
        // return SideTitleWidget(
        //   axisSide: AxisSide.left,
        //   space: 30,
        //   child: Text(DateFormat(DateFormat.ABBR_MONTH_DAY).format(date), style: labelTextStyle),
        // );
      },
      // reservedSize: 25,
    );
  }

  // _getLeftTitles() {
  //   return SideTitles(
  //     showTitles: true,
  //     interval: maxBalance / 3 + 1,
  //     reservedSize: 22,
  //     getTitlesWidget: (double axis, TitleMeta titleMeta) {
  //       double value = axis + minBalance;
  //       return Text(value == 0.0 ? '' : Convert.roundMoney(value), style: labelTextStyle);
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final DateTime frameDate = nowZero.subtract(Duration(days: widget.frameRange));
    final theme = Theme.of(context);
    labelTextStyle = theme.textTheme.labelMedium;

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
            .fold<double>(total, (prev, element) => prev - element.getBalanceFromType());
        frame = [];

        return getGraph(theme, frameDate, transactions);
      },
    );
  }

  Widget getGraph(ThemeData theme, DateTime frameDate, List<Transaction> transactions) {
    transactions.sort((a, b) => b.date.compareTo(a.date));
    frame = calcFrame(transactions, firstBalanceOfFrame ?? 0, frameDate);
    spots = List.generate(widget.frameRange + 1, (index) {
      var balance = frame[index].balance;
      if (balance < minBalance) minBalance = balance;
      if (balance > maxBalance) maxBalance = balance;
      return FlSpot(index.toDouble(), balance);
    });

    final color = theme.colorScheme.primary;
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
          gridData: FlGridData(drawVerticalLine: false, horizontalInterval: maxBalance / 3 + 1),
          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: _getTopTitles()),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            // leftTitles: AxisTitles(axisNameWidget: const Text(''), axisNameSize: 4, sideTitles: _getLeftTitles()),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (value) => value.map((e) {
                return LineTooltipItem(
                  '\$ ${e.y.toInt()} - ${DateFormat(DateFormat.ABBR_MONTH_DAY).format(frame[e.x.toInt()].date)}',
                  const TextStyle(),
                );
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
