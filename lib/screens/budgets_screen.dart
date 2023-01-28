import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/animation_builder/custom_animation_builder.dart';

import '../i18n/index.dart';
import '../common/classes.dart';
import '../model/currency.dart';
import '../model/user.dart';
import '../server/database/budget_rx.dart';
import '../common/convert.dart';
import '../common/styles.dart';
import '../common/theme.dart';
import '../components/empty_list.dart';
import '../components/background_dismissible.dart';
import '../model/budget.dart';
import '../routes.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({Key? key}) : super(key: key);

  @override
  BudgetsScreenState createState() => BudgetsScreenState();
}

class BudgetsScreenState extends State<BudgetsScreen> {
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
              pinned: true,
              leading: getLadingButton(context),
              title: Text('Budgets'.i18n),
            ),
            if (budgets.isEmpty)
              SliverToBoxAdapter(
                child: EmptyList(urlImage: 'assets/images/budget.png', text: 'No budgets by the moment.'.i18n),
              ),
            if (budgets.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: List.generate(
                      budgets.length,
                      (index) => BudgetItem(budget: budgets[index], userId: user.id),
                    ),
                  ),
                ),
              ),
          ],
        ),
        onRefresh: () async => setState(() {}),
      ),
    );
  }
}

class BudgetItem extends StatelessWidget {
  final Budget budget;
  final String userId;

  final SizedBox heightPadding = const SizedBox(height: 7);
  final double widthPaddingValue = 15;
  final double opacitySlide = 0.25;

  const BudgetItem({Key? key, required this.budget, required this.userId}) : super(key: key);

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
            Text(' ${'Edit'.i18n}',
                style: TextStyle(color: primary, fontWeight: FontWeight.w700), textAlign: TextAlign.left),
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
            Text(
              ' ${'Delete'.i18n}',
              style: TextStyle(color: errorColor, fontWeight: FontWeight.w700),
              textAlign: TextAlign.right,
            ),
            Icon(Icons.delete, color: errorColor),
            SizedBox(width: widthPaddingValue),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(budget.id),
      background: const BackgroundDeleteDismissible(),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(budget.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                content: Text('Are you sure you want to delete?'.i18n),
                actions: <Widget>[
                  buttonCancelContext(context),
                  ElevatedButton(
                    style: ButtonThemeStyle.getStyle(ThemeTypes.warn, context),
                    child: Text('Delete'.i18n),
                    onPressed: () {
                      budgetRx.delete(budget.id, userId);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      },
      child: InkWell(
        child: Padding(
          padding: EdgeInsets.only(bottom: 8, top: 8, left: widthPaddingValue, right: widthPaddingValue),
          child: getItems(context),
        ),
        onLongPress: () => RouteApp.redirect(context: context, url: URLS.createOrUpdateBudgets, param: budget),
      ),
    );
  }

  getItems(BuildContext context) {
    final theme = Theme.of(context);
    double sizeBar = MediaQuery.of(context).size.width - (widthPaddingValue * 2);
    int porcentaje = budget.amount == 0.0 ? 0 : ((budget.balance * 100) / budget.amount).round();
    Control control = Control.playFromStart;

    int daysLeft = budget.initialDate.add(Duration(days: budget.period)).difference(DateTime.now()).inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(Convert.capitalize(budget.name), style: theme.textTheme.titleMedium),
            Text(
              daysLeft <= 0 ? 'Finished'.i18n : '%d days left'.plural(daysLeft),
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        heightPadding,
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('BALANCE: ${budget.balance.prettier(withSymbol: true)}', style: theme.textTheme.bodyMedium),
            Text('$porcentaje %', style: theme.textTheme.titleMedium),
          ],
        ),
        heightPadding,
        heightPadding,
        Stack(
          children: [
            Container(
              width: sizeBar,
              height: 10,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: Colors.grey.withOpacity(0.3)),
            ),
            CustomAnimationBuilder<double>(
              control: control,
              tween: Tween<double>(begin: 0.0, end: porcentaje > 0 ? sizeBar * (porcentaje / 100) : 0),
              duration: const Duration(microseconds: 1500),
              builder: (context, value, child) {
                return Container(
                  width: value,
                  height: 10,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: budget.color),
                );
              },
            ),
          ],
        )
      ],
    );
  }
}
