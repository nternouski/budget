import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../i18n/index.dart';
import '../model/currency.dart';

class SelectCurrencyFormField extends FormField<Currency> {
  static final _defaultCurrency = Currency(id: '', name: '', symbol: 'Select Currency'.i18n);
  static String? _defaultValidator(Currency? c) {
    return c == null || c.id == '' ? 'No Currency'.i18n : null;
  }

  final String labelText;

  SelectCurrencyFormField({
    super.key,
    super.enabled = true,
    super.onSaved,
    FormFieldSetter<Currency>? onChange,
    FormFieldValidator<Currency>? validator,
    Currency? initialValue,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    this.labelText = '',
  }) : super(
          validator: validator ?? _defaultValidator,
          initialValue: initialValue ?? _defaultCurrency,
          autovalidateMode: AutovalidateMode.disabled,
          builder: (FormFieldState<Currency> state) {
            final theme = Theme.of(state.context);

            List<Currency> currencies = List.from(Provider.of<List<Currency>>(state.context));
            if (currencies.isEmpty) {
              return Text('No Currency at the moment..'.i18n);
            } else {
              currencies.insert(0, Currency(id: '', name: '', symbol: 'Select Currency'.i18n));

              List<PopupMenuItem<Currency>> items =
                  currencies.map((c) => PopupMenuItem(value: c, child: Center(child: Text(c.symbol)))).toList();

              final valueWidget = Container(
                padding: EdgeInsets.symmetric(vertical: labelText != '' ? 8 : 10, horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: theme.hoverColor,
                  border: state.hasError ? Border.all(width: 2, color: Colors.red) : null,
                ),
                child: Center(
                  child: Text(
                    state.value != null && state.value!.symbol != '' ? state.value!.symbol : _defaultCurrency.symbol,
                    style: theme.textTheme.titleMedium!.copyWith(color: !enabled ? Colors.grey : null),
                  ),
                ),
              );

              return PopupMenuButton<Currency>(
                enabled: enabled,
                onSelected: (c) {
                  if (c.id != '') {
                    if (onChange != null) onChange(c);
                    state.didChange(c);
                    state.validate();
                  }
                },
                itemBuilder: (BuildContext context) => items,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 5, right: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (labelText != '')
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2, left: 5),
                          child: Text(
                            labelText,
                            style: theme.textTheme.bodyMedium!
                                .copyWith(color: theme.hintColor, fontWeight: FontWeight.w600),
                          ),
                        ),
                      valueWidget
                    ],
                  ),
                ),
              );
            }
          },
        );
}
