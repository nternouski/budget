// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../i18n/index.dart';
import '../server/wise_api/wise_api.dart';
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
            getButtonCancelContext(context),
            ElevatedButton(child: Text('YES'.i18n), onPressed: () => Navigator.pop(context, true)),
          ],
        );
      },
    );
  }

  Future<Rate?> _ratesDialog(BuildContext context, User user, CurrencyRate cr) {
    String token = user.integrations[IntegrationType.wise] ?? '';

    return showDialog<Rate>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choice rates'.i18n),
          content: FutureBuilder(
              future: currencyRateApi.fetchRates(cr, token != '' ? WiseApi(token) : null),
              builder: (_, AsyncSnapshot<List<Rate?>> snapshot) {
                if (snapshot.data == null) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [getLoadingProgress(context: context)],
                  );
                } else {
                  final rates = snapshot.data!.where((r) => r != null).toList() as List<Rate>;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${'We found %d new rates'.plural(rates.length)}.'),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text('Do you want to update the rate?'.i18n),
                      ),
                      ...rates.map(
                        (rate) => ElevatedButton(
                          child: Text('${rate.provider}: ${rate.rate}'),
                          onPressed: () => Navigator.pop(context, rate),
                        ),
                      ),
                    ],
                  );
                }
              }),
          actions: <Widget>[getButtonCancelContext(context)],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    CurrencyRate newCurrencyRate = CurrencyRate.init();
    // ignore: unnecessary_cast
    final user = Provider.of<User>(context) as User?;
    if (user == null) return const Text('Not User');

    List<CurrencyRate> currencyRates = Provider.of<List<CurrencyRate>>(context);
    final List<SettingsTile> tiles = [];
    if (currencyRates.isEmpty) {
      tiles.add(
        SettingsTile.navigation(leading: const Icon(Icons.currency_exchange), title: const Text('No Currency rates')),
      );
    } else {
      final titleStyle = theme.textTheme.titleMedium;
      final dataStyle = theme.textTheme.bodyMedium!.copyWith(color: theme.hintColor);

      tiles.addAll(currencyRates
          .map(
            (cr) => SettingsTile.navigation(
              leading: const Icon(Icons.currency_exchange),
              title: Text('${cr.currencyFrom.symbol} - ${cr.currencyTo.symbol}', style: titleStyle),
              value: Text('\$ ${cr.rate}', style: dataStyle),
              trailing: Row(children: [
                IconButton(
                  icon: const Icon(Icons.sync_alt),
                  onPressed: () async {
                    final selected = await _ratesDialog(context, user, cr);
                    if (selected != null) {
                      cr.rate = selected.rate;
                      await currencyRateRx.update(cr, user.id);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final res =
                        await _confirm(context, '${'Delete'.i18n} ${cr.currencyFrom.symbol}-${cr.currencyTo.symbol} ?');
                    if (res == true) await currencyRateRx.delete(cr.id, user.id);
                  },
                )
              ]),
              onPressed: (context) => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                builder: (BuildContext context) => BottomSheet(
                  enableDrag: false,
                  onClosing: () {},
                  builder: (BuildContext context) => _bottomSheet(theme, cr, true, currencyRates, user.id),
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
            Text('Currency Rates'.i18n, style: theme.textTheme.titleMedium!.copyWith(color: theme.colorScheme.primary)),
            InkWell(
              child: const Icon(Icons.add),
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                builder: (BuildContext context) => BottomSheet(
                  enableDrag: false,
                  onClosing: () {},
                  builder: (BuildContext context) =>
                      _bottomSheet(theme, newCurrencyRate, false, currencyRates, user.id),
                ),
              ),
            )
          ]),
      tiles: tiles,
    );
  }

  _bottomSheet(ThemeData theme, CurrencyRate rate, bool update, List<CurrencyRate> currencyRates, String userId) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setStateBottomSheet) {
        bool notExist = currencyRates.notExist(rate.currencyFrom, rate.currencyTo);
        bool differentCurrency =
            rate.currencyFrom.id != rate.currencyTo.id && rate.currencyFrom.id != '' && rate.currencyTo.id != '';
        return SingleChildScrollView(
          child: Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, top: 30, left: 20, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(update ? 'Update'.i18n : 'Create'.i18n, style: theme.textTheme.titleLarge),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: SelectCurrencyFormField(
                        initialValue: rate.currencyFrom,
                        onChange: (c) {
                          if (c != null) setStateBottomSheet(() => rate.currencyFrom = c);
                        },
                        labelText: 'From Rate'.i18n,
                      ),
                    ),
                    Flexible(
                      child: SelectCurrencyFormField(
                        initialValue: rate.currencyTo,
                        onChange: (c) {
                          if (c != null) setStateBottomSheet(() => rate.currencyTo = c);
                        },
                        labelText: 'To Rate'.i18n,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: rate.rate.toString(),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}'))],
                  decoration: const InputDecoration(labelText: 'Rate', hintText: '0'),
                  onChanged: (String value) => rate.rate = double.parse(value != '' ? value : '0.0'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    getButtonCancelContext(context),
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
        );
      },
    );
  }
}
