import 'package:budget/common/title_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:provider/provider.dart';

import '../i18n/index.dart';
import '../server/database/wallet_rx.dart';
import '../common/icon_helper.dart';
import '../components/select_currency.dart';
import '../components/icon_picker.dart';
import '../model/wallet.dart';
import '../common/styles.dart';

class CreateOrUpdateWalletScreen extends StatefulWidget {
  const CreateOrUpdateWalletScreen({Key? key}) : super(key: key);

  @override
  CreateOrUpdateWalletState createState() => CreateOrUpdateWalletState();
}

final now = DateTime.now();

class CreateOrUpdateWalletState extends State<CreateOrUpdateWalletScreen> {
  Wallet wallet = defaultWallet.copy();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final decimalInitialAmountFocusNode = FocusNode();
  final decimalInitialAmountController = TextEditingController(text: '0');
  final sizedBoxHeight = const SizedBox(height: 20);

  @override
  void initState() {
    super.initState();
    decimalInitialAmountFocusNode.addListener(() {
      double? decimal = double.tryParse(decimalInitialAmountController.text);
      if (decimalInitialAmountFocusNode.hasFocus) {
        if (decimal != null && decimal == 0.0) decimalInitialAmountController.text = '';
      } else {
        if (decimal == null) decimalInitialAmountController.text = '0';
      }
    });
  }

  @override
  void dispose() {
    decimalInitialAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = ModalRoute.of(context)!.settings.arguments as Wallet?;

    if (w != null) wallet = w;
    final title = wallet.id == ''
        ? TitleOfComponent(action: TitleAction.create, label: 'Wallet'.i18n)
        : TitleOfComponent(action: TitleAction.update, label: 'Wallet'.i18n);
    final textTheme = Theme.of(context).textTheme;
    decimalInitialAmountController.text = wallet.initialAmount.toString();

    return Scaffold(
      appBar: AppBar(
        titleTextStyle: textTheme.titleLarge,
        leading: getBackButton(context),
        title: title.getTitle(Theme.of(context)),
      ),
      body: CustomScrollView(
        slivers: [SliverToBoxAdapter(child: getForm(title, context))],
      ),
    );
  }

  Widget buildAmount(TitleOfComponent title) {
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Expanded(
        child: SelectCurrencyFormField(
          initialValue: wallet.currency,
          onSaved: (c) {
            wallet.currencyId = c?.id ?? '';
            wallet.currency = c;
          },
          enabled: title.createMode(),
        ),
      ),
      Expanded(
        child: TextFormField(
          controller: decimalInitialAmountController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
          decoration: InputDecoration(
            labelText: 'Initial Amount'.i18n,
            hintText: '',
            prefix: const Text('\$ '),
          ),
          focusNode: decimalInitialAmountFocusNode,
          validator: (String? value) => value!.isEmpty ? 'Is Required'.i18n : null,
          onSaved: (String? value) => wallet.initialAmount = double.parse(value!),
        ),
      ),
    ]);
  }

  Widget buildName() {
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      IconPicker(
        selected: IconMap(wallet.iconName, wallet.icon),
        color: wallet.color,
        onSelected: (iconM) => setState(() {
          wallet.iconName = iconM.name;
          wallet.icon = iconM.icon;
        }),
      ),
      const SizedBox(width: 5),
      Expanded(
          child: TextFormField(
        initialValue: wallet.name,
        decoration: InputDecoration(labelText: 'Wallet Name'.i18n, hintText: 'Bank XX'.i18n),
        inputFormatters: [LengthLimitingTextInputFormatter(Wallet.MAX_LENGTH_NAME)],
        validator: (String? value) => value!.isEmpty ? 'Is Required'.i18n : null,
        onChanged: (String _) => _formKey.currentState!.validate(),
        onSaved: (String? value) => wallet.name = value!,
      )),
    ]);
  }

  Widget getForm(TitleOfComponent title, BuildContext context) {
    auth.User user = Provider.of<auth.User>(context, listen: false);
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(children: <Widget>[
          buildAmount(title),
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
          sizedBoxHeight,
          FilledButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              _formKey.currentState!.save();

              if (title.createMode()) {
                walletRx.create(wallet, user.uid);
              } else {
                walletRx.update(wallet, user.uid);
              }
              Navigator.of(context).pop();
            },
            child: title.getButton(),
          )
        ]),
      ),
    );
  }
}
