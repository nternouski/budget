import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../i18n/index.dart';
import '../components/interaction_border.dart';
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
import '../common/version_checker.dart';
import '../model/user.dart';
import '../model/category.dart';
import '../model/transaction.dart';

class CategorySelected {
  final Category category;
  final bool isSelected;

  CategorySelected({required this.category, required this.isSelected});
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
    // ignore: unnecessary_cast
    final user = Provider.of<User>(context) as User?;

    final adState = Provider.of<AdStateNotifier>(context);
    bool showAds = user?.showAds() ?? true;

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
        title: Text('Statistics'.i18n),
        actions: [
          IconButton(
            icon: Icon(predictionOnStats.enable ? Icons.auto_graph : Icons.visibility_off),
            onPressed: () async {
              if (user != null) await AppVersionChecker().askReview(user, allTransactions);
              predictionOnStats.toggleState();
              Display.message(context, 'Prediction ${predictionOnStats.enable ? 'ON' : 'OFF'}'.i18n);
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<PeriodStats>(
        valueListenable: periods.selected,
        builder: (context, periodStats, child) {
          // Calc frame but respect window and start week from today, the -1 is to start today not yesterday
          final DateTime frameDate =
              nowZero.subtract(Duration(days: frameWindow * (periodStats.days / frameWindow).round() - 1));
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
            final containCategory = (selectedCategories != null && selectedCategories!.contains(t.categoryId));
            return t.date.isAfter(frameDate) && containCategory && selectedTypes[t.type] == true;
          }).toList();

          List<CategorySelected> categoriesSelected = categories
              .map((c) => CategorySelected(
                    category: c,
                    isSelected: selectedCategories != null && selectedCategories!.contains(c.id),
                  ))
              .toList();

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
                        .map((select) => Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
                              child: AppInteractionBorder(
                                oval: true,
                                show: select.value,
                                borderColor: colorsTypeTransaction[select.key]!,
                                margin: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 10),
                                onTap: () => setState(() => selectedTypes.update(select.key, (value) => !value)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: colorsTypeTransaction[select.key],
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(Convert.capitalize(select.key.toShortString()),
                                        style: theme.textTheme.bodyLarge)
                                  ],
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
                child: Column(
                  children: [
                    BarChartWidget(transactions: transactions, frameDate: frameDate, frameWindow: frameWindow),
                    const SizedBox(height: 20),
                    TotalBalance(transactions: transactions, selectedTypes: selectedTypes),
                    StatsPieChart(
                      categoriesSelected: categoriesSelected,
                      transactions: transactions,
                      frameDate: frameDate,
                    ),
                  ],
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
    final theme = Theme.of(context);

    return AppInteractionBorder(
      oval: true,
      show: isSelected,
      borderColor: category.color,
      margin: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 10),
      onTap: () => onTap(!isSelected, category.id),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: category.color),
          ),
          const SizedBox(width: 5),
          Text(category.name, style: theme.textTheme.bodyLarge)
        ],
      ),
    );
  }
}
