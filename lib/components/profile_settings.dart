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
      var emailExceded = user.email.length > textLimit;
      var nameExceded = user.name.length > textLimit;
      var email = emailExceded ? '${user.email.substring(0, textLimit)}..' : user.email;
      var name = nameExceded ? '${user.name.substring(0, textLimit)}..' : user.name;

      String defaultCurrency = '${user.defaultCurrency.symbol} \$ ${user.initialAmount}';
      return SettingsSection(
        title: Text('Profile'.i18n, style: theme.textTheme.titleMedium!.copyWith(color: theme.colorScheme.primary)),
        tiles: [
          SettingsTile.navigation(
            leading: const Icon(Icons.person),
            title: Text('Name'.i18n),
            value: Text(name),
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
            title: const Text('Email'),
            value: Text(email),
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
            title: Text('Initial Amount'.i18n),
            value: Text(defaultCurrency),
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
            buttonCancelContext(context),
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
            child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 10, left: 20, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${'Update'.i18n} ${'Profile'.i18n}', style: theme.textTheme.titleLarge),
                TextFormField(
                  initialValue: user.name,
                  decoration: InputStyle.inputDecoration(labelTextStr: 'Name'.i18n, hintTextStr: ''),
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
                  decoration: InputStyle.inputDecoration(labelTextStr: 'Email', hintTextStr: 'email@email.com'),
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
                      decoration: InputStyle.inputDecoration(
                        labelTextStr: 'Initial Amount'.i18n,
                        hintTextStr: '',
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
                    buttonCancelContext(context),
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
        ));
      },
    );
  }
}
