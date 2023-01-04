import 'package:budget/model/currency.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../common/theme.dart';
import '../components/icon_circle.dart';
import '../server/database/transaction_rx.dart';
import '../routes.dart';
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
  final paddingSlide = const SizedBox(width: 10);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    auth.User user = Provider.of<auth.User>(context);
    List<CurrencyRate> currencyRates = Provider.of<List<CurrencyRate>>(context);
    List<Currency> currencies = List.from(Provider.of<List<Currency>>(context));

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
                      onPressed: () async {
                        await transactionRx.delete(widget.transaction, user.uid, currencyRates, currencies);
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
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
        child: getItem(theme, widget.transaction),
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
            paddingSlide,
            Icon(widget.actionIcon ?? Icons.edit, color: primary),
            Text(
              widget.action ?? ' Edit',
              style: TextStyle(color: primary, fontWeight: FontWeight.w700),
              textAlign: TextAlign.left,
            ),
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
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.name, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 7),
                    Text(transaction.getDateFormat(), style: theme.textTheme.bodyMedium),
                  ],
                ),
              )
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                if (transaction.type == TransactionType.transfer)
                  Text(
                    '(\$${transaction.balanceConverted?.prettier()}) ',
                    style: theme.textTheme.labelMedium?.copyWith(color: colorsTypeTransaction[transaction.type]),
                  ),
                Text(
                  '\$ ${transaction.balanceFixed.abs().prettier()}',
                  style: theme.textTheme.subtitle1?.copyWith(color: colorsTypeTransaction[transaction.type]),
                )
              ],
            ),
            Text('\$ ${transaction.balance.abs().prettier()}', style: TextStyle(color: theme.disabledColor))
          ],
        )
      ],
    );
  }
}
