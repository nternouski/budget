import 'package:flutter/material.dart';

import '../i18n/index.dart';
import '../model/expense_prediction.dart';
import '../model/currency.dart';

class ItemWidget extends StatelessWidget {
  final ExpensePredictionItem item;
  final Color background;

  const ItemWidget({super.key, required this.item, this.background = Colors.transparent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    var titleColor = theme.textTheme.titleMedium?.color;
    final itemColor = item.check ? titleColor : theme.disabledColor;
    final textStyle = theme.textTheme.titleMedium?.copyWith(color: itemColor);

    return Container(
      color: background,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: Text(item.name, overflow: TextOverflow.ellipsis, style: textStyle),
          ),
          Row(children: [
            const Text('  '),
            Text('in %d days '.plural(item.days), style: TextStyle(color: itemColor)),
            Text(item.amount.prettier(withSymbol: true), style: textStyle),
            const SizedBox(width: 30)
          ]),
        ],
      ),
    );
  }
}
