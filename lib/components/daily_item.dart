import 'package:budget/common/classes.dart';
import 'package:budget/model/currency.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../i18n/index.dart';
import '../common/theme.dart';
import '../components/icon_circle.dart';
import '../components/background_dismissible.dart';
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
  final paddingSlide = const SizedBox(width: 10);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    auth.User user = Provider.of<auth.User>(context);
    List<CurrencyRate> currencyRates = Provider.of<List<CurrencyRate>>(context);
    List<Currency> currencies = List.from(Provider.of<List<Currency>>(context));

    return Dismissible(
      key: Key(widget.transaction.id),
      background: const BackgroundDeleteDismissible(),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(widget.transaction.name, style: theme.textTheme.titleLarge),
                content: Text('Are you sure you want to delete?'.i18n),
                actions: <Widget>[
                  getButtonCancelContext(context),
                  FilledButton(
                    style: ButtonThemeStyle.getStyle(ThemeTypes.warn, context),
                    child: Text('Delete'.i18n),
                    onPressed: () => transactionRx
                        .delete(widget.transaction, user.uid, currencyRates, currencies)
                        .then((value) => Navigator.of(context).pop()),
                  ),
                ],
              );
            });
      },
      child: InkWell(
        splashColor: theme.colorScheme.background.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: getItem(theme, widget.transaction),
        ),
        onLongPress: () {
          RouteApp.redirect(context: context, url: URLS.createOrUpdateTransaction, param: widget.transaction);
        },
      ),
    );
  }

  Widget getItem(ThemeData theme, Transaction transaction) {
    final balance = Provider.of<DailyItemBalanceNotifier>(context);
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
                    Text(
                      transaction.getDateFormat(),
                      style: theme.textTheme.bodyMedium!.copyWith(color: theme.hintColor),
                    ),
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
                if (transaction.balanceConverted != null && transaction.type == TransactionType.transfer) ...[
                  transaction.balanceConverted!.prettierToText(
                    withSymbol: true,
                    prefix: '(',
                    style: theme.textTheme.bodyMedium?.copyWith(color: colorsTypeTransaction[transaction.type]),
                    suffix: ') ',
                  ),
                ],
                (balance.showDefault == ShowBalance.original ? transaction.balance : transaction.balanceFixed)
                    .prettierToText(
                  withSymbol: true,
                  style: theme.textTheme.titleMedium?.copyWith(color: colorsTypeTransaction[transaction.type]),
                ),
              ],
            ),
            if (balance.showDefault == ShowBalance.both)
              transaction.balance.prettierToText(
                withSymbol: true,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.disabledColor),
              )
          ],
        )
      ],
    );
  }
}
