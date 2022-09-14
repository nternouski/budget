import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import '../model/currency.dart';
import '../model/user.dart';
import '../common/convert.dart';
import '../common/error_handler.dart';
import '../components/create_or_update_label.dart';
import '../components/icon_circle.dart';
import '../components/create_or_update_category.dart';
import '../screens/wallets_screen.dart';
import '../server/database/transaction_rx.dart';
import '../model/wallet.dart';
import '../model/category.dart';
import '../model/transaction.dart';
import '../common/styles.dart';
import '../routes.dart';

// ignore: constant_identifier_names
const MAX_LENGTH_AMOUNT = 5;

enum Action { create, update }

class CreateOrUpdateTransaction extends StatefulWidget {
  const CreateOrUpdateTransaction({Key? key}) : super(key: key);

  @override
  CreateOrUpdateTransactionState createState() => CreateOrUpdateTransactionState();
}

final now = DateTime.now();

class SelectedType {
  TransactionType type;
  bool isSelected;
  SelectedType(this.type, this.isSelected);
}

class CreateOrUpdateTransactionState extends State<CreateOrUpdateTransaction> {
  HandlerError handlerError = HandlerError();
  Transaction transaction = Transaction(
    id: '',
    name: '',
    amount: 0,
    balance: 0,
    balanceFixed: 0,
    categoryId: '',
    date: now,
    walletId: '',
    type: TransactionType.expense,
    description: '',
    labels: [],
    externalId: '',
  );
  String title = 'Create Transaction';
  Action action = Action.create;
  final ValueNotifier _showDescriptionField = ValueNotifier<bool>(false);
  final TextEditingController dateController = TextEditingController(text: '');
  final TextEditingController timeController = TextEditingController(text: '');
  late List<PopupMenuItem<TransactionType>> types = TransactionType.values
      .map((t) => PopupMenuItem(
          value: t,
          child: Center(
            child: Text(Convert.capitalize(t.toShortString()), style: TextStyle(color: colorsTypeTransaction[t])),
          )))
      .toList();
  Wallet? walletSelected;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final sizedBoxHeight = const SizedBox(height: 20);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = ModalRoute.of(context)!.settings.arguments as Transaction?;
    List<Wallet> wallets = Provider.of<List<Wallet>>(context);

    if (t != null) {
      transaction = t;
      if (t.id != '') {
        walletSelected = wallets.firstWhereOrNull((w) => w.id == transaction.walletId);
        action = Action.update;
        title = 'Update';
      }
    }
    dateController.text = DateFormat('dd/MM/yyyy').format(transaction.date);
    timeController.text = DateFormat('hh:mm').format(transaction.date);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            titleTextStyle: theme.textTheme.titleLarge,
            pinned: true,
            leading: getBackButton(context),
            title: Text('$title ${transaction.name}'),
          ),
          SliverToBoxAdapter(child: getForm(context, wallets, theme))
        ],
      ),
    );
  }

  Widget buildWallet(BuildContext context, String userId, List<Wallet> wallets, Color disabledColor) {
    return Column(
      children: [
        Row(children: [
          const Text('Choose Wallet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => RouteApp.redirect(context: context, url: URLS.createOrUpdateWallet, fromScaffold: false),
          ),
        ]),
        if (wallets.isEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [SizedBox(height: 60), Text('No wallets by the moment.')],
          ),
        if (wallets.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                wallets.length,
                (index) => GestureDetector(
                    onTap: () => setState(() {
                          transaction.walletId = wallets[index].id;
                          walletSelected = wallets[index];
                        }),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: WalletItem(
                        wallet: wallets[index],
                        userId: userId,
                        showBalance: false,
                        showActions: false,
                        selected: transaction.walletId == wallets[index].id,
                      ),
                    )),
              ),
            ),
          ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget buildCategory(List<Category> categories) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => Display.message(context, 'Long press on category to edit it.', seconds: 4),
            ),
            const Text('Choose Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => CreateOrUpdateCategory.showButtonSheet(context, null),
            ),
          ],
        ),
        if (categories.isEmpty)
          SizedBox(
            height: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [Text('No categories by the moment.')],
            ),
          ),
        if (categories.isNotEmpty)
          Align(
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
                      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 15),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconCircle(icon: categories[index].icon, color: categories[index].color),
                          const SizedBox(width: 10),
                          Text(categories[index].name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17))
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextFormField(
            initialValue: transaction.name,
            decoration: InputStyle.inputDecoration(labelTextStr: 'Name', hintTextStr: 'Cookies'),
            validator: (String? value) {
              if (value!.isEmpty) return 'Name is Required.';
              return null;
            },
            onChanged: (String _) => _formKey.currentState!.validate(),
            onSaved: (String? value) => transaction.name = value!,
          ),
        ),
        const SizedBox(width: 5),
        InkWell(
          child: const Icon(Icons.edit_note),
          onTap: () => setState(() => _showDescriptionField.value = !_showDescriptionField.value),
        ),
      ],
    );
  }

  Widget buildDescription() {
    return Column(children: [
      TextFormField(
        key: const Key('normal'),
        initialValue: transaction.description,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        inputFormatters: [LengthLimitingTextInputFormatter(Transaction.MAX_LENGTH_DESCRIPTION)],
        decoration: InputStyle.inputDecoration(labelTextStr: 'Description', hintTextStr: 'Cookies are the best'),
        onSaved: (String? value) => transaction.description = value!,
      ),
      const SizedBox(height: 1)
    ]);
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

  Widget getForm(BuildContext context, List<Wallet> wallets, ThemeData theme) {
    User user = Provider.of<User>(context);
    List<Category> categories = Provider.of<List<Category>>(context);
    List<CurrencyRate> currencyRates = Provider.of<List<CurrencyRate>>(context);

    return Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(flex: 7, child: buildAmount()),
                Flexible(
                  flex: 3,
                  child: PopupMenuButton<TransactionType>(
                    onSelected: (TransactionType item) => setState(() => transaction.type = item),
                    itemBuilder: (BuildContext context) => types,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: borderRadiusApp,
                        color: colorsTypeTransaction[transaction.type]?.withOpacity(0.2),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Center(
                            child: Text(
                              Convert.capitalize(transaction.type.toShortString()),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: colorsTypeTransaction[transaction.type],
                              ),
                            ),
                          )),
                    ),
                  ),
                ),
              ],
            ),
            buildWallet(context, user.id, wallets, theme.disabledColor),
            buildCategory(categories),
            CreateOrUpdateLabel(
              labels: transaction.labels,
              onSelect: (selection) {
                if (!transaction.labels.any((l) => l.id == selection.id)) {
                  setState(() => transaction.labels.add(selection));
                }
              },
              onDelete: (label) => setState(
                () => transaction.labels = transaction.labels.where((l) => l.id != label.id).toList(),
              ),
            ),
            buildName(),
            ValueListenableBuilder(
              valueListenable: _showDescriptionField,
              builder: (BuildContext context, dynamic show, _) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return SizeTransition(sizeFactor: animation, child: child);
                  },
                  child: show ? buildDescription() : const Text(''),
                );
              },
            ),
            buildDateField(),
            sizedBoxHeight,
            sizedBoxHeight,
            ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                _formKey.currentState!.save();
                if (transaction.walletId == '' || walletSelected == null) {
                  return handlerError.setError('You must choice a wallet first');
                }
                if (user.defaultCurrency.id == '') {
                  return handlerError.setError('You must have a default currency first');
                }
                Wallet wallet = wallets.firstWhere((w) => w.id == transaction.walletId);
                transaction.updateBalance();
                if (user.defaultCurrency.id == wallet.currencyId) {
                  transaction.balanceFixed = transaction.balance;
                } else {
                  CurrencyRate? cr = currencyRates.firstWhereOrNull((r) =>
                      ((user.defaultCurrency.id == r.currencyFrom.id && wallet.currencyId == r.currencyTo.id) ||
                          (user.defaultCurrency.id == r.currencyTo.id && wallet.currencyId == r.currencyFrom.id)));
                  if (cr != null) {
                    bool fromTo =
                        user.defaultCurrency.id == cr.currencyFrom.id && wallet.currencyId == cr.currencyTo.id;
                    transaction.balanceFixed = double.parse(
                      (fromTo ? transaction.balance * cr.rate : transaction.balance / cr.rate).toStringAsFixed(2),
                    );
                  } else {
                    String defaultSymbol = user.defaultCurrency.symbol;
                    String tSymbol = wallet.currency?.symbol ?? '';
                    String message =
                        'No currency rate of $defaultSymbol-$tSymbol or $tSymbol-$defaultSymbol, please add it before.';
                    return HandlerError().setError(message);
                  }
                }
                if (transaction.categoryId == '') return handlerError.setError('You must choice a category first');
                if (transaction.amount <= 0.0) {
                  return handlerError.setError('Amount is required and must be grater than 0.');
                }
                if (action == Action.create) {
                  await transactionRx.create(transaction, user.id, walletSelected!);
                } else {
                  await transactionRx.update(transaction, user.id, walletSelected!);
                }
                Navigator.of(context).pop();
              },
              child: Text(title),
            ),
            sizedBoxHeight,
            sizedBoxHeight,
          ]),
        ));
  }
}
