import 'package:budget/model/currency.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectCurrency extends StatelessWidget {
  final String defaultCurrencyId;
  final Function(Currency) onSelect;

  const SelectCurrency({Key? key, required this.defaultCurrencyId, required this.onSelect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<List<Currency>>(
      builder: (context, data, child) {
        final currencies = List<Currency>.from(data);
        currencies.insert(0, Currency(id: '', name: '', symbol: 'Select Currency'));
        if (currencies.isEmpty) {
          return const Text('No Currency by the moment.');
        } else {
          return InputDecorator(
            decoration: const InputDecoration(labelText: ''),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: defaultCurrencyId,
                isDense: true,
                onChanged: (String? id) => id != null ? onSelect(currencies.firstWhere((c) => c.id == id)) : null,
                items: currencies.map((c) => DropdownMenuItem(value: c.id, child: Text(c.symbol))).toList(),
              ),
            ),
          );
        }
      },
    );
  }
}
