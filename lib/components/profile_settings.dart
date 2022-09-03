import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:settings_ui/settings_ui.dart';

import 'package:budget/common/styles.dart';
import 'package:budget/components/select_currency.dart';
import 'package:budget/model/user.dart';
import 'package:budget/server/user_service.dart';

class ProfileSettings extends AbstractSettingsSection {
  final int textLimit = 22;
  final User user;

  const ProfileSettings({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      var emailExceded = user.email.length > textLimit;
      var nameExceded = user.name.length > textLimit;
      var email = emailExceded ? '${user.email.substring(0, textLimit)}..' : user.email;
      var name = nameExceded ? '${user.name.substring(0, textLimit)}..' : user.name;

      String defaultCurrency = 'No set yet';
      if (user.defaultCurrency != null) {
        defaultCurrency = '${user.defaultCurrency!.symbol} - Initial Amount \$ ${user.initialAmount}';
      }
      return SettingsSection(
        title: const Text('Profile', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
        tiles: [
          SettingsTile.navigation(
            leading: const Icon(Icons.person),
            title: const Text('Name'),
            value: Text(name),
            onPressed: (context) => showModalBottomSheet(
              enableDrag: true,
              context: context,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              builder: (BuildContext context) => BottomSheet(
                enableDrag: false,
                onClosing: () {},
                builder: (BuildContext context) => _bottomSheet(setState),
              ),
            ),
          ),
          SettingsTile.navigation(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            value: Text(email),
            onPressed: (context) => showModalBottomSheet(
              enableDrag: true,
              context: context,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              builder: (BuildContext context) => BottomSheet(
                enableDrag: false,
                onClosing: () {},
                builder: (BuildContext context) => _bottomSheet(setState),
              ),
            ),
          ),
          SettingsTile.navigation(
            leading: const Icon(Icons.currency_exchange),
            title: const Text('Default Currency'),
            value: Text(defaultCurrency),
            onPressed: (context) => showModalBottomSheet(
              enableDrag: true,
              context: context,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              builder: (BuildContext context) => BottomSheet(
                enableDrag: false,
                onClosing: () {},
                builder: (BuildContext context) => _bottomSheet(setState),
              ),
            ),
          ),
        ],
      );
    });
  }

  _bottomSheet(StateSetter setState) {
    const sizedBoxHeight = SizedBox(height: 20);

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
                const Text('Update Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextFormField(
                  initialValue: user.name,
                  decoration: InputStyle.inputDecoration(labelTextStr: 'Name', hintTextStr: 'John Doe'),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z1-9  ]')),
                    LengthLimitingTextInputFormatter(30)
                  ],
                  validator: (String? value) => value!.isEmpty ? 'Name is Required.' : null,
                  onChanged: (String name) => user.name = name,
                ),
                sizedBoxHeight,
                TextFormField(
                  initialValue: user.email,
                  decoration: InputStyle.inputDecoration(labelTextStr: 'Email', hintTextStr: 'email@email.com'),
                  validator: (String? value) => value!.isEmpty ? 'Email is Required.' : null,
                  onChanged: (String email) => user.email = email,
                ),
                sizedBoxHeight,
                TextFormField(
                  initialValue: user.initialAmount.toString(),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.]'))],
                  decoration: InputStyle.inputDecoration(
                    labelTextStr: 'Initial Amount',
                    hintTextStr: '0',
                    prefix: const Text('\$ '),
                  ),
                  validator: (String? value) => value!.isEmpty ? 'Amount is Required.' : null,
                  onChanged: (String value) => user.initialAmount = double.parse(value != '' ? value : '0'),
                ),
                SelectCurrency(
                  defaultCurrencyId: user.defaultCurrencyId,
                  onSelect: (c) => setStateBottomSheet(() {
                    user.defaultCurrencyId = c.id;
                    user.defaultCurrency = c;
                  }),
                ),
                sizedBoxHeight,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buttonCancelContext(context),
                    ElevatedButton(
                      child: const Text('Update'),
                      onPressed: () {
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
