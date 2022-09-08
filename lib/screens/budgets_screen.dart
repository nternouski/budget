import 'package:budget/common/classes.dart';
import 'package:budget/model/user.dart';
import 'package:budget/server/database/budget_rx.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../common/convert.dart';
import '../common/styles.dart';
import '../common/theme.dart';
import '../components/empty_list.dart';
import '../model/budget.dart';
import '../routes.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({Key? key}) : super(key: key);

  @override
  BudgetsScreenState createState() => BudgetsScreenState();
}

class BudgetsScreenState extends State<BudgetsScreen> {
  final SizedBox heightPadding = const SizedBox(height: 7);
  final double widthPaddingValue = 20;
  final double opacitySlide = 0.25;

  @override
  Widget build(BuildContext context) {
    List<Budget> budgets = Provider.of<List<Budget>>(context);
    final theme = Theme.of(context);

    User? user = Provider.of<User>(context);

    if (user == null) return ScreenInit.getScreenInit(context);

    return Scaffold(
      body: RefreshIndicator(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverAppBar(
              titleTextStyle: theme.textTheme.titleLarge,
              actionsIconTheme: Theme.of(context).iconTheme,
              actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
              pinned: true,
              leading: getLadingButton(context),
              title: const Text('Budgets'),
            ),
            if (budgets.isEmpty)
              const SliverToBoxAdapter(
                child: EmptyList(urlImage: 'assets/images/budget.png', text: 'No budgets by the moment.'),
              ),
            if (budgets.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Column(
                    children: List.generate(budgets.length, (index) => getBudget(budgets[index], theme, user.id)),
                  ),
                ),
              ),
          ],
        ),
        onRefresh: () async => setState(() {}),
      ),
    );
  }

  Widget slideRightBackground(Color primary) {
    return Container(
      color: primary.withOpacity(opacitySlide),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: widthPaddingValue),
            Icon(Icons.edit, color: primary),
            Text(' Edit', style: TextStyle(color: primary, fontWeight: FontWeight.w700), textAlign: TextAlign.left),
          ],
        ),
      ),
    );
  }

  Widget slideLeftBackground(Color errorColor) {
    return Container(
      color: errorColor.withOpacity(opacitySlide),
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(' Delete',
                style: TextStyle(color: errorColor, fontWeight: FontWeight.w700), textAlign: TextAlign.right),
            Icon(Icons.delete, color: errorColor),
            SizedBox(width: widthPaddingValue),
          ],
        ),
      ),
    );
  }

  getBudget(Budget budget, ThemeData themeData, String userId) {
    double sizeBar = MediaQuery.of(context).size.width - (widthPaddingValue * 2);
    int porcentaje = budget.amount == 0.0 ? 0 : ((budget.balance * 100) / budget.amount).round();
    return Dismissible(
      key: Key(budget.id),
      background: slideRightBackground(themeData.colorScheme.primary),
      secondaryBackground: slideLeftBackground(themeData.colorScheme.error),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          final bool res = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(budget.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  content: const Text('Are you sure you want to delete ?'),
                  actions: <Widget>[
                    buttonCancelContext(context),
                    ElevatedButton(
                      style: ButtonThemeStyle.getStyle(ThemeTypes.warn, context),
                      child: const Text('Delete'),
                      onPressed: () {
                        budgetRx.delete(budget.id, userId);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });
          return res;
        } else {
          RouteApp.redirect(context: context, url: URLS.createOrUpdateBudgets, param: budget);
        }
        return null;
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 8, top: 8, left: widthPaddingValue, right: widthPaddingValue),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Convert.capitalize(budget.name), style: themeData.textTheme.titleMedium),
            heightPadding,
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'BALANCE: \$${Convert.roundDouble(budget.balance, 2)}',
                  style: themeData.textTheme.bodyMedium,
                ),
                Text('$porcentaje %', style: themeData.textTheme.titleMedium),
              ],
            ),
            heightPadding,
            heightPadding,
            Stack(
              children: [
                Container(
                  width: sizeBar,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
                Container(
                  width: porcentaje > 0 ? sizeBar * (porcentaje / 100) : 0,
                  height: 10,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: budget.color),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
