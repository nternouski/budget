import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:provider/provider.dart';

import '../common/error_handler.dart';
import '../server/database/wallet_rx.dart';
import '../common/icon_helper.dart';
import '../components/select_currency.dart';
import '../components/icon_picker.dart';
import '../model/wallet.dart';
import '../common/styles.dart';

enum Action { create, update }

class CreateOrUpdateWalletScreen extends StatefulWidget {
  const CreateOrUpdateWalletScreen({Key? key}) : super(key: key);

  @override
  CreateOrUpdateWalletState createState() => CreateOrUpdateWalletState();
}

final now = DateTime.now();

class CreateOrUpdateWalletState extends State<CreateOrUpdateWalletScreen> {
  HandlerError handlerError = HandlerError();

  Wallet wallet = defaultWallet.copy();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final sizedBoxHeight = const SizedBox(height: 20);

  @override
  Widget build(BuildContext context) {
    final w = ModalRoute.of(context)!.settings.arguments as Wallet?;

    if (w != null) wallet = w;
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
          SliverToBoxAdapter(child: getForm(action, title, context))
        ],
      ),
    );
  }

  Widget buildAmount(Action action) {
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Expanded(
        child: TextFormField(
          initialValue: wallet.initialAmount.toString(),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
          decoration: InputStyle.inputDecoration(
            labelTextStr: 'Initial Amount',
            hintTextStr: '1300',
            prefix: const Text('\$ '),
          ),
          validator: (String? value) => value!.isEmpty ? 'Amount is Required.' : null,
          onSaved: (String? value) => wallet.initialAmount = double.parse(value!),
        ),
      ),
      Expanded(
        child: SelectCurrency(
          initialCurrencyId: wallet.currencyId,
          onSelect: (c) => setState(() {
            wallet.currencyId = c.id;
            wallet.currency = c;
          }),
          disabled: action == Action.update,
        ),
      ),
    ]);
  }

  Widget buildName() {
    return TextFormField(
      initialValue: wallet.name,
      decoration: InputStyle.inputDecoration(labelTextStr: 'Wallet Name', hintTextStr: 'Bank'),
      inputFormatters: [LengthLimitingTextInputFormatter(Wallet.MAX_LENGTH_NAME)],
      validator: (String? value) => value!.isEmpty ? 'Name is Required.' : null,
      onChanged: (String _) => _formKey.currentState!.validate(),
      onSaved: (String? value) => wallet.name = value!,
    );
  }

  Widget getForm(Action action, String title, BuildContext context) {
    auth.User user = Provider.of<auth.User>(context, listen: false);
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(children: <Widget>[
          buildAmount(action),
          buildName(),
          ColorPicker(
            color: wallet.color,
            width: 35,
            height: 35,
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
              if (!_formKey.currentState!.validate()) return;
              _formKey.currentState!.save();
              if (wallet.currency == null) return handlerError.setError('Currency is required');

              if (action == Action.create) {
                walletRx.create(wallet, user.uid);
              } else {
                walletRx.update(wallet, user.uid);
              }
              Navigator.of(context).pop();
            },
            child: Text(title),
          )
        ]),
      ),
    );
  }
}
