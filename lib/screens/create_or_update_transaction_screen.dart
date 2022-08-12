import 'package:budget/components/create_or_update_label.dart';
import 'package:budget/components/icon_circle.dart';
import 'package:budget/model/wallet.dart';
import 'package:budget/routes.dart';
import 'package:budget/screens/wallets_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../components/create_or_update_category.dart';
import '../model/category.dart';
import '../model/transaction.dart';
import '../server/model_rx.dart';
import '../common/styles.dart';

// ignore: constant_identifier_names
const MAX_LENGTH_AMOUNT = 5;

enum Action { create, update }

class CreateOrUpdateTransaction extends StatefulWidget {
  final Transaction? transaction;

  const CreateOrUpdateTransaction({this.transaction, Key? key}) : super(key: key);

  @override
  CreateOrUpdateTransactionState createState() => CreateOrUpdateTransactionState(transaction);
}

final now = DateTime.now();

class SelectedType {
  TransactionType type;
  bool isSelected;
  SelectedType(this.type, this.isSelected);
}

class CreateOrUpdateTransactionState extends State<CreateOrUpdateTransaction> {
  late Transaction transaction;
  late String title;
  late Action action;
  late TextEditingController dateController;
  late TextEditingController timeController;
  late List<SelectedType> types;

  CreateOrUpdateTransactionState(Transaction? t) {
    if (t != null) {
      action = Action.update;
      title = 'Update transaction';
      transaction = t;
    } else {
      action = Action.create;
      title = 'Create transaction';
      transaction = Transaction(
        id: '',
        name: '',
        amount: 0,
        balance: 0,
        categoryId: '',
        date: now,
        walletId: '',
        type: TransactionType.expense,
        description: '',
        labels: [],
      );
    }
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
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            titleTextStyle: theme.textTheme.titleLarge,
            pinned: true,
            leading: getBackButton(context),
            title: Text('$title ${transaction.name}'),
          ),
          SliverToBoxAdapter(child: getForm(theme))
        ],
      ),
    );
  }

  Widget buildWallet(Color disabledColor) {
    return Column(
      children: [
        Row(children: [
          const Text('Choose wallet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                    children: List.generate(
                      wallets.length,
                      (index) => GestureDetector(
                          onTap: () => setState(() => transaction.walletId = wallets[index].id),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: WalletItem(
                              wallet: wallets[index],
                              showBalance: false,
                              showActions: false,
                              selected: transaction.walletId == wallets[index].id,
                            ),
                          )),
                    ),
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
            const Text('Choose category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                            border: Border.all(width: 2, color: colorItem),
                            borderRadius: categoryBorderRadius,
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
        const Text('Long press for edit category.'),
        sizedBoxHeight,
      ],
    );
  }

  Widget buildAmount() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 3,
          child: TextFormField(
            initialValue: transaction.amount.toInt().toString(),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(MAX_LENGTH_AMOUNT)
            ],
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(border: InputBorder.none, hintText: '\$ 0'),
            onSaved: (String? value) {
              final decimals = transaction.amount.toString().split('.')[1];
              transaction.amount = double.parse('$value.$decimals');
            },
          ),
        ),
        Flexible(
          flex: 1,
          child: TextFormField(
            initialValue: transaction.amount.toString().split('.')[1],
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
            textAlign: TextAlign.start,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(border: InputBorder.none, hintText: '00'),
            onSaved: (String? value) {
              final intValue = transaction.amount.toString().split('.')[0];
              transaction.amount = double.parse('$intValue.$value');
            },
          ),
        )
      ],
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
            decoration: InputStyle.inputDecoration(labelTextStr: 'Time', hintTextStr: formatTime),
            validator: (String? value) {
              return value!.isEmpty ? 'Date is Required.' : null;
            },
          ),
        ),
      ],
    );
  }

  Widget getForm(ThemeData theme) {
    return Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(children: <Widget>[
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(child: buildAmount()),
              Expanded(
                child: ToggleButtons(
                  onPressed: (int index) => setState(() {
                    for (int i = 0; i < types.length; i++) {
                      types[i].isSelected = i == index;
                    }
                    transaction.type = types[index].type;
                  }),
                  isSelected: types.map((t) => t.isSelected).toList(),
                  children: types.map((t) => Text(t.type.toShortString())).toList(),
                ),
              ),
            ]),
            buildWallet(theme.disabledColor),
            buildCategory(),
            CreateOrUpdateLabel(
              labels: transaction.labels,
              onSelect: (selection) => setState(() => transaction.labels.add(selection)),
              onDelete: (label) => setState(
                () => transaction.labels = transaction.labels.where((l) => l.id != label.id).toList(),
              ),
            ),
            buildName(),
            buildDescription(),
            buildDateField(),
            sizedBoxHeight,
            sizedBoxHeight,
            ElevatedButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                if (transaction.walletId == '') {
                  return displayError(context, 'You must choice a wallet first');
                }
                if (transaction.categoryId == '') {
                  return displayError(context, 'You must choice a category first');
                }
                _formKey.currentState!.save();
                if (transaction.amount <= 0.0) {
                  return displayError(context, 'Amount is Required and must be grater than 0.');
                }
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
            ),
            sizedBoxHeight,
          ]),
        ));
  }
}
