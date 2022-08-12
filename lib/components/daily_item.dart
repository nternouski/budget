import 'package:budget/common/theme.dart';
import 'package:budget/components/icon_circle.dart';
import 'package:budget/routes.dart';
import 'package:budget/server/model_rx.dart';
import 'package:flutter/material.dart';
import '../common/styles.dart';
import '../model/transaction.dart';

class DailyItem extends StatefulWidget {
  final Transaction transaction;

  const DailyItem({Key? key, required this.transaction}) : super(key: key);

  @override
  DailyItemState createState() => DailyItemState();
}

class DailyItemState extends State<DailyItem> {
  final double opacitySlide = 0.25;
  final paddingSlide = const SizedBox(width: 20);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: Key(widget.transaction.id),
      background: slideRightBackground(theme.colorScheme.primary),
      secondaryBackground: slideLeftBackground(theme.colorScheme.error),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          final bool res = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(widget.transaction.name, style: Theme.of(context).textTheme.titleLarge),
                  content: const Text('Are you sure you want to delete ?'),
                  actions: <Widget>[
                    buttonCancelContext(context),
                    ElevatedButton(
                      style: ButtonThemeStyle.getStyle(ThemeTypes.warn, context),
                      child: const Text('Delete', style: TextStyle(fontSize: 17)),
                      onPressed: () {
                        transactionRx.delete(widget.transaction.id);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });
          return res;
        } else {
          RouteApp.redirect(context: context, url: URLS.createOrUpdateTransaction, param: widget.transaction);
        }
        return null;
      },
      child: Padding(padding: const EdgeInsets.only(left: 20, right: 20), child: getItem(widget.transaction)),
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
            paddingSlide,
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
            paddingSlide,
          ],
        ),
      ),
    );
  }

  Widget getItem(Transaction transaction) {
    var size = MediaQuery.of(context).size;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: (size.width - 40) * 0.7,
              child: Row(
                children: [
                  IconCircle(icon: transaction.category.icon, color: transaction.category.color),
                  paddingSlide,
                  SizedBox(
                    width: (size.width - 90) * 0.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(transaction.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                        const SizedBox(height: 5),
                        Text(transaction.getDateFormat(), style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              width: (size.width - 40) * 0.3,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '\$ ${transaction.amount}',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15, color: colorsTypeTransaction[transaction.type]),
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
