import 'package:budget/components/icon_circle.dart';
import 'package:budget/model/wallet.dart';
import 'package:budget/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../components/create_or_update_category.dart';
import '../model/category.dart';
import '../model/transaction.dart';
import '../server/model_rx.dart';
import '../common/color_constants.dart';
import '../common/styles.dart';

// ignore: constant_identifier_names
const MAX_LENGTH_AMOUNT = 5;

enum Action { create, update }

class CreateOrUpdateTransaction extends StatefulWidget {
  late Transaction _transaction;
  late String _title;
  late Action _action;

  CreateOrUpdateTransaction({Transaction? transaction, Key? key}) : super(key: key) {
    if (transaction != null) {
      _action = Action.update;
      _title = "Update transaction";
      _transaction = transaction;
    } else {
      _action = Action.create;
      _title = "Create transaction";
      _transaction = Transaction(
        name: "",
        amount: 1,
        balance: 0,
        categoryId: "",
        date: now,
        walletId: "",
        type: TransactionType.expense,
        description: "",
        id: "",
      );
    }
  }

  @override
  _CreateOrUpdateTransactionState createState() => _CreateOrUpdateTransactionState(_transaction, _title, _action);
}

final now = DateTime.now();

class SelectedType {
  TransactionType type;
  bool isSelected;
  SelectedType(this.type, this.isSelected);
}

class _CreateOrUpdateTransactionState extends State<CreateOrUpdateTransaction> {
  final Transaction transaction;
  final String title;
  late final Action action;
  late TextEditingController dateController;
  late TextEditingController timeController;
  late List<SelectedType> types;

  _CreateOrUpdateTransactionState(this.transaction, this.title, this.action) {
    categoryRx.getAll();
    walletRx.getAll();
    dateController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(transaction.date));
    timeController = TextEditingController(text: DateFormat('hh:mm').format(transaction.date));
    types = TransactionType.values.map((t) => SelectedType(t, transaction.type == t)).toList();
  }

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
                        children: [Text('$title ${transaction.name}', style: titleStyle)])
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

  Widget buildWallet() {
    return Column(
      children: [
        Row(children: [
          Text(
            "Choose wallet",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: black.withOpacity(0.5)),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => RouteApp.redirect(context: context, url: URLS.createOrUpdateWallet, fromScaffold: false),
          ),
        ]),
        StreamBuilder<List<Wallet>>(
          stream: walletRx.fetchRx,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              final wallets = List<Wallet>.from(snapshot.data!);
              if (wallets.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [SizedBox(height: 60), Text('No wallets by the moment.')],
                );
              } else {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(wallets.length, (index) {
                      var isSelected = transaction.walletId == wallets[index].id;
                      var colorItem = isSelected ? wallets[index].color : grey.withOpacity(0.5);
                      return GestureDetector(
                        onTap: () => setState(() => transaction.walletId = wallets[index].id),
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorItem,
                              borderRadius: borderRadiusApp,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(7),
                              child: Row(
                                children: [
                                  Icon(wallets[index].icon, color: TextColor.getContrastOf(colorItem)),
                                  const SizedBox(width: 5),
                                  Text(
                                    wallets[index].name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: TextColor.getContrastOf(colorItem)),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }
            } else {
              return Text('Error on Wallets: ${snapshot.error.toString()}');
            }
          },
        ),
      ],
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
                      var colorItem =
                          transaction.categoryId == categories[index].id ? categories[index].color : Colors.transparent;
                      return GestureDetector(
                        onLongPress: () => CreateOrUpdateCategory.showButtonSheet(context, categories[index]),
                        onTap: () => setState(() => transaction.categoryId = categories[index].id),
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

  Widget buildAmount() {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.45,
        child: TextFormField(
          initialValue: transaction.amount.toString(),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(MAX_LENGTH_AMOUNT)
          ],
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: black),
          decoration: const InputDecoration(border: InputBorder.none, hintText: "\$ 0"),
          validator: (String? value) {
            if (value!.isEmpty || double.parse(value) == 0) return 'Amount is Required.';
            return null;
          },
          onSaved: (String? value) {
            transaction.amount = double.parse(value!);
          },
        ),
      ),
    );
  }

  Widget buildName() {
    return TextFormField(
      initialValue: transaction.name,
      decoration: InputStyle.inputDecoration(labelTextStr: 'Name', hintTextStr: 'Cookies'),
      validator: (String? value) {
        if (value!.isEmpty) return 'Name is Required.';
        return null;
      },
      onSaved: (String? value) {
        transaction.name = value!;
      },
    );
  }

  Widget buildDescription() {
    return TextFormField(
      initialValue: transaction.description,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      inputFormatters: [LengthLimitingTextInputFormatter(Transaction.MAX_LENGTH_DESCRIPTION)],
      decoration: InputStyle.inputDecoration(labelTextStr: 'Description', hintTextStr: 'Cookies are the best'),
      onSaved: (String? value) => transaction.description = value!,
    );
  }

  // DATE PICKER //

  Widget buildDateField() {
    const formatDate = 'dd/MM/yyyy';
    const formatTime = 'hh:mm';
    return Row(
      children: <Widget>[
        Flexible(
          child: TextFormField(
            controller: dateController,
            onTap: () async {
              // Below line stops keyboard from appearing
              FocusScope.of(context).requestFocus(FocusNode());
              // Show Date Picker Here
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: transaction.date,
                firstDate: DateTime(2010),
                lastDate: DateTime.now(),
              );
              if (picked != null && picked != transaction.date) {
                setState(() => transaction.date = picked);
              }
              dateController.text = DateFormat(formatDate).format(transaction.date);
            },
            decoration: InputStyle.inputDecoration(labelTextStr: 'Date', hintTextStr: formatDate),
            validator: (String? value) => value!.isEmpty ? 'Date is Required.' : null,
          ),
        ),
        Flexible(
          child: TextFormField(
            controller: timeController,
            onTap: () async {
              // Below line stops keyboard from appearing
              FocusScope.of(context).requestFocus(FocusNode());
              // Show Date Picker Here
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: transaction.date.hour, minute: transaction.date.minute),
              );
              if (picked != null && picked != transaction.getTime()) {
                setState(() {
                  transaction.setTime(hour: picked.hour, minute: picked.minute);
                });
              }
              timeController.text = DateFormat(formatTime).format(transaction.date);
            },
            decoration: InputStyle.inputDecoration(labelTextStr: "Time", hintTextStr: formatTime),
            validator: (String? value) {
              return value!.isEmpty ? 'Date is Required.' : null;
            },
          ),
        ),
      ],
    );
  }

  Widget getForm() {
    return Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(children: <Widget>[
            ToggleButtons(
              onPressed: (int index) => setState(() {
                for (int i = 0; i < types.length; i++) {
                  types[i].isSelected = i == index;
                }
                transaction.type = types[index].type;
              }),
              isSelected: types.map((t) => t.isSelected).toList(),
              children: types.map((t) => Text(t.type.toShortString())).toList(),
            ),
            buildWallet(),
            buildAmount(),
            buildCategory(),
            buildName(),
            buildDescription(),
            buildDateField(),
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
                      if (!_formKey.currentState!.validate()) return;
                      if (transaction.walletId == '') {
                        displayError(context, 'You must choice a wallet first');
                        return;
                      }
                      _formKey.currentState!.save();
                      if (action == Action.create) {
                        transaction.updateBalance();
                        transactionRx.create(transaction);
                      } else {
                        transaction.updateBalance();
                        transactionRx.update(transaction);
                      }
                      Navigator.of(context).pop();
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
