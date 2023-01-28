import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../i18n/index.dart';
import '../model/currency.dart';

class SelectCurrency extends StatelessWidget {
  final String initialCurrencyId;
  final bool disabled;
  final String labelText;
  final Function(Currency) onSelect;

  const SelectCurrency({
    Key? key,
    this.disabled = false,
    this.labelText = '',
    required this.initialCurrencyId,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<Currency> currencies = List.from(Provider.of<List<Currency>>(context));

    if (currencies.isEmpty) {
      return Text('No Currency by the moment.'.i18n);
    } else {
      currencies.insert(0, Currency(id: '', name: '', symbol: 'Select Currency'.i18n));

      Currency selected = currencies.firstWhere((c) => c.id == initialCurrencyId);
      List<PopupMenuItem<Currency>> items = currencies
          .map(
            (c) => PopupMenuItem(value: c, child: Center(child: Text(c.symbol))),
          )
          .toList();

      var textStyle = theme.textTheme.titleMedium!.copyWith(color: selected.id == '' ? Colors.grey : null);

      return PopupMenuButton<Currency>(
        onSelected: (Currency c) => c.id != '' ? onSelect(c) : c,
        itemBuilder: (BuildContext context) => items,
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 5, right: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (labelText != '') Padding(padding: const EdgeInsets.only(bottom: 2, left: 5), child: Text(labelText)),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: theme.cardColor),
                child: Center(child: Text(selected.symbol, style: textStyle)),
              )
            ],
          ),
        ),
      );
    }
  }
}
