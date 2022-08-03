import 'package:budget/common/styles.dart';
import 'package:budget/model/budget.dart';
import 'package:budget/routes.dart';
import 'package:budget/server/model_rx.dart';
import 'package:flutter/material.dart';
import '../common/color_constants.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({Key? key}) : super(key: key);

  @override
  _BudgetsScreenState createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  final SizedBox heightPadding = const SizedBox(height: 7);
  final double widthPaddingValue = 20;
  final double opacitySlide = 0.1;

  @override
  Widget build(BuildContext context) {
    budgetRx.getAll();
    return Scaffold(
      backgroundColor: white,
      body: RefreshIndicator(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: getBody(),
        ),
        onRefresh: () => budgetRx.getAll(),
      ),
    );
  }

  List<Widget> getBody() {
    return [
      SliverAppBar(
        pinned: true,
        backgroundColor: white,
        leading: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: IconButton(
            icon: const Icon(Icons.menu, color: black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [Text('Budgets', style: titleStyle), Icon(Icons.search, color: black)],
        ),
      ),
      StreamBuilder<List<Budget>>(
        stream: budgetRx.fetchRx,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final budgets = List<Budget>.from(snapshot.data!);
            if (budgets.isEmpty) {
              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [SizedBox(height: 60), Text('No budgets by the moment.', style: titleStyle)],
                ),
              );
            } else {
              return SliverList(
                delegate: SliverChildBuilderDelegate((_, idx) => getBudget(budgets[idx]), childCount: budgets.length),
              );
            }
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            return const SliverToBoxAdapter(child: Text('Hubo un error inesperado en budgets_screen'));
          }
        },
      ),
    ];
  }

  Widget slideRightBackground() {
    return Container(
      color: green.withOpacity(opacitySlide),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: widthPaddingValue),
            const Icon(Icons.edit, color: green),
            const Text(' Edit', style: TextStyle(color: green, fontWeight: FontWeight.w700), textAlign: TextAlign.left),
          ],
        ),
      ),
    );
  }

  Widget slideLeftBackground() {
    return Container(
      color: Colors.red.withOpacity(opacitySlide),
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(' Delete',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700), textAlign: TextAlign.right),
            const Icon(Icons.delete, color: Colors.red),
            SizedBox(width: widthPaddingValue),
          ],
        ),
      ),
    );
  }

  getBudget(Budget budget) {
    double sizeBar = MediaQuery.of(context).size.width - (widthPaddingValue * 2);
    int porcentaje = ((budget.balance * 100) / budget.amount).round();
    return Dismissible(
      key: Key(budget.id),
      background: slideRightBackground(),
      secondaryBackground: slideLeftBackground(),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          final bool res = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(budget.name, style: titleStyle),
                  content: const Text('Are you sure you want to delete ?'),
                  actions: <Widget>[
                    buttonCancelContext(context),
                    ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                      child: const Text('Delete', style: TextStyle(fontSize: 17)),
                      onPressed: () {
                        budgetRx.delete(budget.id);
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
      child: InkWell(
        onTap: () => print('${budget.name} clicked'),
        child: Padding(
          padding: EdgeInsets.only(bottom: 8, top: 8, left: widthPaddingValue, right: widthPaddingValue),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${budget.name}     \$${budget.balance.toString()}', style: bodyTextStyle),
              heightPadding,
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TOTAL: \$ ${budget.amount.round()}', style: textGreyStyle),
                  Text('$porcentaje %', style: textGreyStyle),
                ],
              ),
              heightPadding,
              Stack(
                children: [
                  Container(
                    width: sizeBar,
                    height: 5,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: grey.withOpacity(0.3)),
                  ),
                  Container(
                    width: sizeBar * (porcentaje / 100),
                    height: 5,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: budget.color),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
