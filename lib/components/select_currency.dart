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
    List<Currency> currencies = List.from(Provider.of<List<Currency>>(context));
    if (currencies.isEmpty) {
      return Text('No Currency by the moment.'.i18n);
    } else {
      currencies.insert(0, Currency(id: '', name: '', symbol: 'Select Currency'.i18n));
      return InputDecorator(
        decoration: InputDecoration(labelText: '  $labelText'),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isDense: true,
            value: initialCurrencyId,
            onChanged: disabled
                ? null
                : (String? id) => id != '' && id != null ? onSelect(currencies.firstWhere((c) => c.id == id)) : null,
            items: currencies
                .map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Center(
                        child: Text('  ${c.symbol}', style: TextStyle(color: c.id == '' ? Colors.grey : null)),
                      ),
                    ))
                .toList(),
          ),
        ),
      );
    }
  }
}
