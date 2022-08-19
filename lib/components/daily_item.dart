import 'package:budget/common/theme.dart';
import 'package:budget/components/icon_circle.dart';
import '../routes.dart';
import 'package:budget/server/model_rx.dart';
import 'package:flutter/material.dart';
import '../common/styles.dart';
import '../model/transaction.dart';

class DailyItem extends StatefulWidget {
  final Transaction transaction;
  final String? action;
  final IconData? actionIcon;

  const DailyItem({Key? key, required this.transaction, this.action, this.actionIcon}) : super(key: key);

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
                  title: Text(widget.transaction.name, style: theme.textTheme.titleLarge),
                  content: const Text('Are you sure you want to delete ?'),
                  actions: <Widget>[
                    buttonCancelContext(context),
                    ElevatedButton(
                      style: ButtonThemeStyle.getStyle(ThemeTypes.warn, context),
                      child: const Text('Delete'),
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
      child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
          child: getItem(theme, widget.transaction)),
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
            Icon(widget.actionIcon ?? Icons.edit, color: primary),
            Text(widget.action ?? ' Edit',
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
            Text(' Delete',
                style: TextStyle(color: errorColor, fontWeight: FontWeight.w700), textAlign: TextAlign.right),
            Icon(Icons.delete, color: errorColor),
            paddingSlide,
          ],
        ),
      ),
    );
  }

  Widget getItem(ThemeData theme, Transaction transaction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconCircle(icon: transaction.category.icon, color: transaction.category.color),
        paddingSlide,
        Flexible(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.name, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 7),
                  Text(transaction.getDateFormat(), style: theme.textTheme.bodyMedium),
                ],
              )
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '\$ ${transaction.amount}',
              style: theme.textTheme.subtitle1?.copyWith(color: colorsTypeTransaction[transaction.type]),
            )
          ],
        )
      ],
    );
  }
}
