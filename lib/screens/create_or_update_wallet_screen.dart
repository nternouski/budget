import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

import '../common/icon_helper.dart';
import '../components/select_currency.dart';
import '../components/icon_picker.dart';
import '../routes.dart';
import '../model/wallet.dart';
import '../server/model_rx.dart';
import '../common/styles.dart';

enum Action { create, update }

class CreateOrUpdateWalletScreen extends StatefulWidget {
  final Wallet? wallet;

  const CreateOrUpdateWalletScreen({required this.wallet, Key? key}) : super(key: key);

  @override
  CreateOrUpdateWalletState createState() => CreateOrUpdateWalletState(wallet);
}

final now = DateTime.now();

class CreateOrUpdateWalletState extends State<CreateOrUpdateWalletScreen> {
  late Wallet wallet;

  CreateOrUpdateWalletState(Wallet? w) {
    wallet = w ?? defaultWallet;
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final sizedBoxHeight = const SizedBox(height: 20);

  @override
  Widget build(BuildContext context) {
    final action = wallet.id == '' ? Action.create : Action.update;
    final title = wallet.id == '' ? 'Create Wallet' : 'Update Wallet';
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            titleTextStyle: textTheme.titleLarge,
            pinned: true,
            leading: getBackButton(context),
            title: Text('$title ${wallet.name}'),
          ),
          SliverToBoxAdapter(child: getForm(action, title))
        ],
      ),
    );
  }

  Widget buildAmount() {
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Expanded(
        child: TextFormField(
          initialValue: wallet.initialAmount.toString(),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.]'))],
          decoration: InputStyle.inputDecoration(
            labelTextStr: 'Initial Amount',
            hintTextStr: '1300',
            prefix: const Text('\$ '),
          ),
          validator: (String? value) {
            if (value!.isEmpty) return 'Amount is Required.';
            return null;
          },
          onSaved: (String? value) => wallet.initialAmount = double.parse(value!),
        ),
      ),
      Expanded(
        child: SelectCurrency(
          defaultCurrencyId: wallet.currencyId,
          onSelect: (c) => setState(() => wallet.currencyId = c.id),
        ),
      ),
    ]);
  }

  Widget buildName() {
    return TextFormField(
      initialValue: wallet.name,
      decoration: InputStyle.inputDecoration(labelTextStr: 'Wallet Name', hintTextStr: 'Bank'),
      validator: (String? value) {
        if (value!.isEmpty) return 'Name is Required.';
        return null;
      },
      onSaved: (String? value) => wallet.name = value!,
    );
  }

  Widget getForm(Action action, String title) {
    return Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(children: <Widget>[
            buildAmount(),
            sizedBoxHeight,
            buildName(),
            ColorPicker(
              color: wallet.color,
              width: 40,
              height: 40,
              padding: const EdgeInsets.only(top: 16, bottom: 0),
              borderRadius: 25,
              enableShadesSelection: false,
              onColorChanged: (Color color) => setState(() => wallet.color = color),
              pickersEnabled: const {
                ColorPickerType.both: true,
                ColorPickerType.primary: false,
                ColorPickerType.accent: false,
              },
            ),
            IconPicker.picker(
              IconMap(wallet.iconName, wallet.icon),
              (iconM) => setState(() {
                wallet.iconName = iconM.name;
                wallet.icon = iconM.icon;
              }),
            ),
            sizedBoxHeight,
            ElevatedButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                _formKey.currentState!.save();
                if (action == Action.create) {
                  walletRx.create(wallet);
                } else {
                  walletRx.update(wallet);
                }
                RouteApp.redirect(context: context, url: URLS.wallets, fromScaffold: false);
              },
              child: Text(title),
            )
          ]),
        ));
  }
}
