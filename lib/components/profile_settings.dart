import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../i18n/index.dart';
import '../components/select_currency.dart';
import '../model/currency.dart';
import '../common/error_handler.dart';
import '../common/styles.dart';
import '../model/user.dart';
import '../server/user_service.dart';

class ProfileSettings extends AbstractSettingsSection {
  final int textLimit = 25;
  final User user;

  const ProfileSettings({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StatefulBuilder(builder: (context, setState) {
      final emailExceded = user.email.length > textLimit;
      final nameExceded = user.name.length > textLimit;
      final email = emailExceded ? '${user.email.substring(0, textLimit)}..' : user.email;
      final name = nameExceded ? '${user.name.substring(0, textLimit)}..' : user.name;

      final titleStyle = theme.textTheme.titleMedium;
      final dataStyle = theme.textTheme.bodyMedium!.copyWith(color: theme.hintColor);
      String defaultCurrency = '${user.defaultCurrency.symbol} \$ ${user.initialAmount}';
      return SettingsSection(
        title: Text('Profile'.i18n, style: theme.textTheme.titleMedium!.copyWith(color: theme.colorScheme.primary)),
        tiles: [
          SettingsTile.navigation(
            leading: const Icon(Icons.person),
            title: Text('Name'.i18n, style: titleStyle),
            value: Text(name, style: dataStyle),
            onPressed: (context) => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              builder: (BuildContext context) => BottomSheet(
                enableDrag: false,
                onClosing: () {},
                builder: (BuildContext context) => _bottomSheet(context, setState),
              ),
            ),
          ),
          SettingsTile.navigation(
            leading: const Icon(Icons.email),
            title: Text('Email', style: titleStyle),
            value: Text(email, style: dataStyle),
            onPressed: (context) => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              builder: (BuildContext context) => BottomSheet(
                enableDrag: false,
                onClosing: () {},
                builder: (BuildContext context) => _bottomSheet(context, setState),
              ),
            ),
          ),
          SettingsTile.navigation(
            leading: const Icon(Icons.currency_exchange),
            title: Text('Initial Amount'.i18n, style: titleStyle),
            value: Text(defaultCurrency, style: dataStyle),
            onPressed: (context) => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              builder: (BuildContext context) => BottomSheet(
                enableDrag: false,
                onClosing: () {},
                builder: (BuildContext context) => _bottomSheet(context, setState),
              ),
            ),
          ),
        ],
      );
    });
  }

  Future<bool?> _confirm(BuildContext context, String body) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'.i18n),
          content: Text(body),
          actions: <Widget>[
            getButtonCancelContext(context),
            ElevatedButton(
              child: Text('YES'.i18n),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );
  }

  _bottomSheet(BuildContext context, StateSetter setState) {
    final theme = Theme.of(context);
    const sizedBoxHeight = SizedBox(height: 20);
    List<CurrencyRate> currencyRates = Provider.of<List<CurrencyRate>>(context);

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setStateBottomSheet) {
        return SingleChildScrollView(
          child: Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, top: 30, left: 20, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${'Update'.i18n} ${'Profile'.i18n}', style: theme.textTheme.titleLarge),
                TextFormField(
                  initialValue: user.name,
                  decoration: InputDecoration(labelText: 'Name'.i18n, hintText: ''),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z1-9  ]')),
                    LengthLimitingTextInputFormatter(30)
                  ],
                  validator: (String? value) => value!.isEmpty ? '${'Name'.i18n} ${'Is Required'.i18n}' : null,
                  onChanged: (String name) => user.name = name,
                ),
                sizedBoxHeight,
                TextFormField(
                  initialValue: user.email,
                  autovalidateMode: AutovalidateMode.always,
                  decoration: const InputDecoration(labelText: 'Email', hintText: 'email@email.com'),
                  validator: (String? value) =>
                      value != null && value.isValidEmail() ? null : 'Email ${'Is Required'.i18n}.',
                  onChanged: (String email) => user.email = email,
                ),
                sizedBoxHeight,
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  if (user.superUser)
                    Expanded(
                      child: SelectCurrencyFormField(
                        key: Key(Random().nextDouble().toString()),
                        initialValue: user.defaultCurrency,
                        labelText: 'Default Currency'.i18n,
                        onChange: (selected) async {
                          if (selected == null) return;
                          var confirm = await _confirm(
                            context,
                            '${'The new default currency will be'.i18n} ${selected.name}',
                          );
                          if (confirm == true) {
                            await UserService()
                                .updateCurrency(user, selected, currencyRates)
                                .catchError((err) => HandlerError().setError(err.toString()));
                            setStateBottomSheet(() {});
                            setState(() {});
                            Navigator.pop(context);
                          } else {
                            setStateBottomSheet(() {
                              user.defaultCurrency = user.defaultCurrency;
                            });
                          }
                        },
                      ),
                    ),
                  Expanded(
                    child: TextFormField(
                      initialValue: user.initialAmount.toString(),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                      decoration: InputDecoration(
                        labelText: 'Initial Amount'.i18n,
                        hintText: '',
                        prefix: const Text('\$ '),
                      ),
                      validator: (String? value) => value!.isEmpty ? 'Is Required'.i18n : null,
                      onChanged: (String value) => user.initialAmount = double.parse(value != '' ? value : '0'),
                    ),
                  ),
                ]),
                sizedBoxHeight,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    getButtonCancelContext(context),
                    ElevatedButton(
                      child: Text('Update'.i18n),
                      onPressed: () {
                        if (user.defaultCurrency.id == '') {
                          return HandlerError().showError(context, text: 'The default currency must be set'.i18n);
                        }
                        UserService().update(user);
                        setState(() {});
                        Navigator.pop(context);
                      },
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
