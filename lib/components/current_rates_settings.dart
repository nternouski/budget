// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../i18n/index.dart';
import '../server/currency_rates_service.dart';
import '../server/database/currency_rate_rx.dart';
import '../model/currency.dart';
import '../common/styles.dart';
import '../components/select_currency.dart';
import '../model/user.dart';

class CurrentRatesSettings extends AbstractSettingsSection {
  final User user;
  final CurrencyRateApi currencyRateApi = CurrencyRateApi();

  CurrentRatesSettings({Key? key, required this.user}) : super(key: key);

  Future<bool?> _confirm(BuildContext context, String content) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'.i18n),
          content: Text(content),
          actions: <Widget>[
            buttonCancelContext(context),
            ElevatedButton(child: Text('YES'.i18n), onPressed: () => Navigator.pop(context, true)),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    CurrencyRate newCurrencyRate = CurrencyRate.init();
    auth.User user = Provider.of<auth.User>(context);

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
              trailing: Row(children: [
                IconButton(
                  icon: const Icon(Icons.sync_alt),
                  onPressed: () async {
                    final rate = await currencyRateApi.fetchRate(cr);
                    final res = await _confirm(
                      context,
                      '${'We found a new rate.'.i18n} ${cr.currencyFrom.symbol}-${cr.currencyTo.symbol}: \$$rate. ${'Update Currency Rate?'.i18n}',
                    );
                    if (res == true) {
                      cr.rate = rate;
                      await currencyRateRx.update(cr, user.uid);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final res =
                        await _confirm(context, '${'Delete'.i18n} ${cr.currencyFrom.symbol}-${cr.currencyTo.symbol} ?');
                    if (res == true) await currencyRateRx.delete(cr.id, user.uid);
                  },
                )
              ]),
              onPressed: (context) => showModalBottomSheet(
                enableDrag: true,
                context: context,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                builder: (BuildContext context) => BottomSheet(
                  enableDrag: false,
                  onClosing: () {},
                  builder: (BuildContext context) => _bottomSheet(cr, true, currencyRates, user.uid),
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
            Text('Currency Rates'.i18n, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
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
                  builder: (BuildContext context) => _bottomSheet(newCurrencyRate, false, currencyRates, user.uid),
                ),
              ),
            )
          ]),
      tiles: tiles,
    );
  }

  _bottomSheet(CurrencyRate rate, bool update, List<CurrencyRate> currencyRates, String userId) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setStateBottomSheet) {
        bool notExist = currencyRates.notExist(rate.currencyFrom, rate.currencyTo);

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
                Text(update ? 'Update'.i18n : 'Create'.i18n,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: SelectCurrency(
                        initialCurrencyId: rate.currencyFrom.id,
                        onSelect: (c) => setStateBottomSheet(() => rate.currencyFrom = c),
                        labelText: 'From Rate'.i18n,
                      ),
                    ),
                    Flexible(
                      child: SelectCurrency(
                        initialCurrencyId: rate.currencyTo.id,
                        onSelect: (c) => setStateBottomSheet(() => rate.currencyTo = c),
                        labelText: 'To Rate'.i18n,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: rate.rate.toString(),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
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
                              Navigator.pop(context);
                            }
                          : null,
                      child: Text(update ? 'Update'.i18n : 'Create'.i18n),
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
