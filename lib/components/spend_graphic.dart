import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../common/classes.dart';
import '../common/theme.dart';
import '../server/database/transaction_rx.dart';
import '../model/currency.dart';
import '../model/wallet.dart';
import '../model/user.dart';
import '../model/transaction.dart';

// ignore: constant_identifier_names
const OPACITY = 0.2;
// ignore: constant_identifier_names
const HEIGHT_GRAPHIC = 190.0;

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
      reservedSize: 7,
      getTitlesWidget: (double axis, TitleMeta titleMeta) => const SizedBox(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime frameDate = nowZero.subtract(Duration(days: widget.frameRange));
    final theme = Theme.of(context);

    return StreamBuilder<List<Transaction>>(
      stream: transactionRx.getTransactions(widget.user.id),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState.name == 'waiting') {
          return SizedBox(
            height: HEIGHT_GRAPHIC,
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

        return _getGraph(theme, frameDate, transactions);
      },
    );
  }

  Widget _getGraph(ThemeData theme, DateTime frameDate, List<Transaction> transactions) {
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
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [color.withOpacity(0.7), color.withOpacity(OPACITY)],
    );
    List<HorizontalLine> hLines = [maxBalance / 1.5, maxBalance / 4.5]
        .map(
          (y) => HorizontalLine(
            y: y,
            color: color,
            strokeWidth: 0.5,
            dashArray: [4, 7],
            label: HorizontalLineLabel(
              show: true,
              padding: const EdgeInsets.only(right: 5, bottom: 5),
              style: CurrencyPrettier.getFont(theme.textTheme.bodyMedium!.copyWith(color: color)),
              labelResolver: (line) => '  ${line.y.prettier(withSymbol: true, simplify: true)}',
            ),
          ),
        )
        .toList();

    final dot = FlDotCirclePainter(radius: 6, color: theme.colorScheme.primary);

    return Container(
      padding: const EdgeInsets.all(0),
      width: double.infinity,
      height: HEIGHT_GRAPHIC,
      child: LineChart(
        LineChartData(
          minY: 0,
          gridData: FlGridData(show: false),
          extraLinesData: ExtraLinesData(horizontalLines: hLines),
          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: _getTopTitles()),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineTouchData: LineTouchData(
            getTouchedSpotIndicator: (barData, spotIndexes) => spotIndexes
                .map(
                  (e) => TouchedSpotIndicatorData(
                    FlLine(strokeWidth: 0),
                    FlDotData(getDotPainter: (spot, percent, barData, index) => dot),
                  ),
                )
                .toList(growable: false),
            getTouchLineEnd: (_, __) => 0,
            touchTooltipData: LineTouchTooltipData(
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (value) => value.map((e) {
                return LineTooltipItem(
                  '${e.y.roundToDouble().prettier(withSymbol: true)} - ${DateFormat(DateFormat.ABBR_MONTH_DAY).format(frame[e.x.toInt()].date)}',
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
