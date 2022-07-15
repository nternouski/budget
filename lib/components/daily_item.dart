import 'package:budget/common/styles.dart';
import 'package:budget/screens/create_or_update_budget_screen.dart';
import 'package:flutter/material.dart';
import '../common/color_constants.dart';
import '../model/budget.dart';
import '../json/create_budget_json.dart';

class DailyItem extends StatefulWidget {
  Budget budget;

  DailyItem(this.budget, {Key? key}) : super(key: key);

  @override
  _DailyItemState createState() => _DailyItemState(budget);
}

class _DailyItemState extends State<DailyItem> {
  Budget budget;

  final double opacitySlide = 0.1;
  final paddingSlide = const SizedBox(width: 20);

  _DailyItemState(this.budget);

  @override
  Widget build(BuildContext context) {
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
                  content: const Text("Are you sure you want to delete ?"),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("Cancel", style: TextStyle(color: Colors.black)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: const Text("Delete", style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        setState(() {
                          // TODO: Delete the item from DB etc..
                          // itemsList.removeAt(index);
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });
          return res;
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => CreateOrUpdateBudget(budget: budget),
            ),
          );
        }
        return null;
      },
      child: InkWell(
        onTap: () {
          print("${budget.name} clicked");
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: getItem(budget),
        ),
      ),
    );
  }

  Widget slideRightBackground() {
    return Container(
      color: green.withOpacity(opacitySlide),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            paddingSlide,
            const Icon(Icons.edit, color: green),
            const Text(" Edit", style: TextStyle(color: green, fontWeight: FontWeight.w700), textAlign: TextAlign.left),
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
            const Text(" Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700), textAlign: TextAlign.right),
            const Icon(Icons.delete, color: Colors.red),
            paddingSlide,
          ],
        ),
      ),
    );
  }

  Widget getItem(Budget budget) {
    var size = MediaQuery.of(context).size;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: (size.width - 40) * 0.7,
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: grey.withOpacity(0.1)),
                    child: Center(
                      child: Image.asset(
                        categories.firstWhere((book) => book.id == budget.categoryId, orElse: () => categories[0]).icon,
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                  paddingSlide,
                  Container(
                    width: (size.width - 90) * 0.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.name,
                          style: bodyTextStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          budget.getDateFormat(),
                          style: TextStyle(fontSize: 12, color: black.withOpacity(0.5), fontWeight: FontWeight.w400),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: (size.width - 40) * 0.3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '\$ ${budget.amount}',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: colorsTypeBudget[budget.type]),
                  ),
                ],
              ),
            )
          ],
        ),
        const Padding(padding: EdgeInsets.only(left: 65, top: 10))
      ],
    );
  }
}
