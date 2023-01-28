import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../i18n/index.dart';
import '../components/pie_chart.dart';
import '../components/stats_widget.dart';
import '../components/bar_chart.dart';
import '../components/spend_graphic.dart';
import '../common/error_handler.dart';
import '../common/prediction_on_stats.dart';
import '../common/ad_helper.dart';
import '../common/convert.dart';
import '../common/period_stats.dart';
import '../common/preference.dart';
import '../common/styles.dart';
import '../model/expense_prediction.dart';
import '../model/user.dart';
import '../model/category.dart';
import '../model/transaction.dart';

class CategorySelected {
  final Category category;
  late double totalAmount;
  final bool isSelected;

  CategorySelected(this.category, this.isSelected, {this.totalAmount = 0});
}

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  StatsScreenState createState() => StatsScreenState();
}

class StatsScreenState extends State<StatsScreen> {
  Preferences preferences = Preferences();
  List<String>? selectedCategories;
  Map<TransactionType, bool> selectedTypes = TransactionType.values.asMap().map((_, value) => MapEntry(value, true));

  BannerAd? banner;
  int _bannerAdRetry = 0;

  final frameWindow = 7;

  StatsScreenState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<Transaction> allTransactions = Provider.of<List<Transaction>>(context);
    final adState = Provider.of<AdStateNotifier>(context);
    bool showAds = Provider.of<User>(context)?.showAds() ?? true;

    if (showAds && banner == null && _bannerAdRetry <= AdStateNotifier.MAXIMUM_NUMBER_OF_AD_REQUEST) {
      _bannerAdRetry++;
      banner = BannerAd(
          size: AdSize.largeBanner,
          adUnitId: adState.bannerAdUnitId,
          listener: adState.bannerAdListener(onFailed: () {
            setState(() => banner = null);
          }),
          request: const AdRequest())
        ..load();
    }

    PredictionOnStatsNotifier predictionOnStats = Provider.of<PredictionOnStatsNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        titleTextStyle: theme.textTheme.titleLarge,
        leading: getBackButton(context),
        title: Text('Stats'.i18n),
        actions: [
          IconButton(
            icon: Icon(predictionOnStats.enable ? Icons.auto_graph : Icons.visibility_off),
            onPressed: () {
              predictionOnStats.toggleState();
              Display.message(context, 'Prediction ${predictionOnStats.enable ? 'ON' : 'OFF'}'.i18n);
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<PeriodStats>(
        valueListenable: periods.selected,
        builder: (context, periodStats, child) {
          // Calc frame but respect window and start week from today
          final DateTime frameDate =
              nowZero.subtract(Duration(days: frameWindow * (periodStats.days / frameWindow).round()));
          List<Category> categories = Provider.of<List<Category>>(context)
              .where((c) => allTransactions.any((t) => t.categoryId == c.id))
              .toList();
          selectedCategories ??= categories.isEmpty ? null : categories.map((c) => c.id).toList();
          double totalExpensePeriod = 0.0;
          var transactions = allTransactions.where((t) {
            // calc totalPeriod to compare prediction
            if (t.date.isAfter(frameDate) && t.type == TransactionType.expense) {
              totalExpensePeriod += t.balanceFixed.abs();
            }
            return t.date.isAfter(frameDate) &&
                selectedCategories!.contains(t.categoryId) &&
                selectedTypes[t.type] == true;
          }).toList();

          double totalSelected = 0;
          List<CategorySelected> categoriesSelected = categories.map((c) {
            bool isSelected = selectedCategories != null && selectedCategories!.contains(c.id);
            double acc = transactions.fold<double>(0.0, (p, t) => t.categoryId == c.id ? p + t.balanceFixed.abs() : p);
            totalSelected += isSelected ? acc : 0;
            return CategorySelected(c, isSelected, totalAmount: acc);
          }).toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(
                child: Column(children: [
                  StatsBalance(transactions: allTransactions),
                  const SizedBox(height: 10),
                  if (banner != null) SizedBox(height: banner!.size.height.toDouble(), child: AdWidget(ad: banner!)),
                  const SizedBox(height: 10),
                  Text('${'Period'.i18n}: ${periodStats.humanize}', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  StatsPrediction(totalExpensePeriod: totalExpensePeriod, periodStats: periodStats),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: selectedTypes.entries
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
                              child: GestureDetector(
                                onTap: () => setState(() => selectedTypes.update(e.key, (value) => !value)),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: e.value ? Border.all(width: 2, color: colorsTypeTransaction[e.key]!) : null,
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
                    padding: const EdgeInsets.all(5),
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
              SliverToBoxAdapter(
                child: BarChartWidget(
                  transactions: transactions,
                  selectedTypes: selectedTypes,
                  frameDate: frameDate,
                  frameWindow: frameWindow,
                ),
              ),
              SliverToBoxAdapter(
                child: StatsPieChart(
                  categoriesSelected: categoriesSelected,
                  transactions: transactions,
                  total: totalSelected,
                  periodStats: periodStats,
                ),
              ),
            ],
          );
        },
      ),
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
