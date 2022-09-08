import 'package:budget/server/database/currency_rate_rx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../model/currency.dart';
import '../common/styles.dart';
import '../components/select_currency.dart';
import '../model/user.dart';

class CurrentRatesSettings extends AbstractSettingsSection {
  final User user;

  const CurrentRatesSettings({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CurrencyRate newCurrencyRate = CurrencyRate.init();
    auth.User user = Provider.of<auth.User>(context);

    return StatefulBuilder(builder: (context, setState) {
      List<CurrencyRate> currencyRates = Provider.of<List<CurrencyRate>>(context);
      final List<SettingsTile> tiles = [];
      if (currencyRates.isEmpty) {
        tiles.add(
          SettingsTile.navigation(leading: const Icon(Icons.currency_exchange), title: const Text('No Currency rates')),
        );
      } else {
        tiles.addAll(currencyRates
            .map(
              (cr) => SettingsTile.navigation(
                leading: const Icon(Icons.currency_exchange),
                title: Text('${cr.currencyFrom.symbol} - ${cr.currencyTo.symbol}'),
                value: Text('\$ ${cr.rate}'),
                onPressed: (context) => showModalBottomSheet(
                  enableDrag: true,
                  context: context,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  builder: (BuildContext context) => BottomSheet(
                    enableDrag: false,
                    onClosing: () {},
                    builder: (BuildContext context) => _bottomSheet(cr, true, currencyRates, setState, user.uid),
                  ),
                ),
              ),
            )
            .toList());
      }
      return SettingsSection(
        title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Currency Rates', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
              InkWell(
                child: const Icon(Icons.add),
                onTap: () => showModalBottomSheet(
                  enableDrag: true,
                  context: context,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  builder: (BuildContext context) => BottomSheet(
                    enableDrag: false,
                    onClosing: () {},
                    builder: (BuildContext context) =>
                        _bottomSheet(newCurrencyRate, false, currencyRates, setState, user.uid),
                  ),
                ),
              )
            ]),
        tiles: tiles,
      );
    });
  }

  _bottomSheet(CurrencyRate rate, bool update, List<CurrencyRate> currencyRates, StateSetter setState, String userId) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setStateBottomSheet) {
        bool notExist = currencyRates
            .where((cr) => cr.currencyFrom.id == rate.currencyFrom.id && cr.currencyTo.id == rate.currencyTo.id)
            .isEmpty;

        bool differentCurrency = rate.currencyFrom.id != rate.currencyTo.id;
        return SingleChildScrollView(
            child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 10, left: 20, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(update ? 'Update Rate' : 'Create Rate',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: SelectCurrency(
                        defaultCurrencyId: rate.currencyFrom.id,
                        onSelect: (c) => setStateBottomSheet(() => rate.currencyFrom = c),
                        labelText: 'From',
                      ),
                    ),
                    Flexible(
                      child: SelectCurrency(
                        defaultCurrencyId: rate.currencyTo.id,
                        onSelect: (c) => setStateBottomSheet(() => rate.currencyTo = c),
                        labelText: 'To',
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: rate.rate.toString(),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.]'))],
                  decoration: InputStyle.inputDecoration(labelTextStr: 'Rate', hintTextStr: '0'),
                  onChanged: (String value) => rate.rate = double.parse(value != '' ? value : '0.0'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buttonCancelContext(context),
                    ElevatedButton(
                      onPressed: differentCurrency && (update || notExist)
                          ? () {
                              update ? currencyRateRx.update(rate, userId) : currencyRateRx.create(rate, userId);
                              setState(() {});
                              Navigator.pop(context);
                            }
                          : null,
                      child: Text(update ? 'Update' : 'Create'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
      },
    );
  }
}
