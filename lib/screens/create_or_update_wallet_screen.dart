import 'package:budget/common/icon_helper.dart';
import 'package:budget/components/create_or_update_category.dart';
import 'package:budget/components/icon_circle.dart';
import 'package:budget/components/icon_picker.dart';
import 'package:budget/model/category.dart';
import 'package:budget/model/currency.dart';
import 'package:budget/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

import '../model/wallet.dart';
import '../server/model_rx.dart';
import '../common/color_constants.dart';
import '../common/styles.dart';

enum Action { create, update }

class CreateOrUpdateWalletScreen extends StatefulWidget {
  late Wallet _wallet;
  late String _title;
  late Action _action;

  CreateOrUpdateWalletScreen({Wallet? wallet, Key? key}) : super(key: key) {
    if (wallet != null) {
      _action = Action.update;
      _title = 'Update wallet';
      _wallet = wallet;
    } else {
      _action = Action.create;
      _title = 'Create wallet';
      _wallet = Wallet(
        id: '',
        createdAt: DateTime.now(),
        name: '',
        color: 'ff00ffff',
        iconName: 'question_mark',
        initialAmount: 0,
        currencyId: '',
        userId: userId,
        categories: [],
        balance: 0,
      );
    }
  }

  @override
  _CreateOrUpdateWalletState createState() => _CreateOrUpdateWalletState(_wallet, _title, _action);
}

final now = DateTime.now();

class _CreateOrUpdateWalletState extends State<CreateOrUpdateWalletScreen> {
  final Wallet wallet;
  final String title;
  final Action action;

  _CreateOrUpdateWalletState(this.wallet, this.title, this.action);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final sizedBoxHeight = const SizedBox(height: 20);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: white,
                boxShadow: [BoxShadow(color: grey.withOpacity(0.01), spreadRadius: 10, blurRadius: 3)],
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 60, right: 20, left: 20, bottom: 25),
                child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('$title ${wallet.name}', style: titleStyle)])
                  ],
                ),
              ),
            ),
            sizedBoxHeight,
            getForm()
          ],
        ),
      ),
    );
  }

  Widget buildAmount() {
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Expanded(
        child: TextFormField(
          initialValue: wallet.initialAmount.toString(),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9.]"))],
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
      StreamBuilder<List<Currency>>(
        stream: currencyRx.fetchRx,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final currencies = List<Currency>.from(snapshot.data!);
            currencies.insert(0, Currency(id: '', name: '', symbol: 'Select Currency'));
            if (currencies.isEmpty) {
              return const Text('No Currency by the moment.');
            } else {
              return Expanded(
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Select Plan'),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: wallet.currencyId,
                      isDense: true,
                      onChanged: (String? id) => id != null ? setState(() => wallet.currencyId = id) : null,
                      items: currencies.map((c) => DropdownMenuItem(value: c.id, child: Text(c.symbol))).toList(),
                    ),
                  ),
                ),
              );
            }
          } else {
            return Text(snapshot.error.toString());
          }
        },
      )
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

  _showDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: ColorPicker(
                    color: wallet.color,
                    width: 40,
                    height: 40,
                    borderRadius: 25,
                    enableShadesSelection: false,
                    onColorChanged: (Color color) => setState(() {
                      wallet.color = color;
                      Navigator.of(context).pop();
                    }),
                    heading: const Text('Select color', style: titleStyle),
                    pickersEnabled: const {
                      ColorPickerType.primary: true,
                      ColorPickerType.accent: true,
                      ColorPickerType.custom: true,
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildCategory() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "Choose category",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: black.withOpacity(0.5)),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => CreateOrUpdateCategory.showButtonSheet(context, null),
            ),
          ],
        ),
        StreamBuilder<List<Category>>(
          stream: categoryRx.fetchRx,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              final categories = List<Category>.from(snapshot.data!);
              if (categories.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [SizedBox(height: 60), Text('No categories by the moment.')],
                );
              } else {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(categories.length, (index) {
                      var colorItem = wallet.categories.any((c) => c.id == categories[index].id)
                          ? categories[index].color
                          : Colors.transparent;
                      return GestureDetector(
                        onLongPress: () => CreateOrUpdateCategory.showButtonSheet(context, categories[index]),
                        onTap: () => setState(() => {
                              if (wallet.categories.any((c) => c.id == categories[index].id))
                                {wallet.categories.remove(categories[index])}
                              else
                                {wallet.categories.add(categories[index])}
                            }),
                        child: Container(
                          decoration: BoxDecoration(
                            color: white,
                            border: Border.all(width: 2, color: colorItem),
                            borderRadius: borderRadiusApp,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconCircle(icon: categories[index].icon, color: categories[index].color),
                                Text(categories[index].name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17))
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }
            } else {
              return Text('Error on Categories: ${snapshot.error.toString()}');
            }
          },
        ),
        const SizedBox(height: 10),
        const Text("Long press for edit category."),
        sizedBoxHeight,
      ],
    );
  }

  Widget getForm() {
    return Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(children: <Widget>[
            buildAmount(),
            sizedBoxHeight,
            buildName(),
            buildCategory(),
            Padding(
              padding: const EdgeInsets.only(top: 25, left: 5, bottom: 10),
              child: Row(children: [
                const Text("Color selected: ", style: titleStyle),
                ColorIndicator(
                  width: 30,
                  height: 30,
                  borderRadius: 25,
                  color: wallet.color,
                  onSelectFocus: false,
                  onSelect: () async => _showDialog(context),
                ),
              ]),
            ),
            IconPicker.picker(
              IconMap(wallet.iconName, wallet.icon),
              (iconM) => setState(() {
                wallet.iconName = iconM.name;
                wallet.icon = iconM.icon;
              }),
            ),
            sizedBoxHeight,
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buttonCancelContext(context),
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
                    child: Text(title, style: const TextStyle(fontSize: 17)),
                  )
                ],
              ),
            )
          ]),
        ));
  }
}
