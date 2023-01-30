// ignore_for_file: use_build_context_synchronously
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import '../i18n/index.dart';
import '../common/ad_helper.dart';
import '../components/choose_category.dart';
import '../model/currency.dart';
import '../model/user.dart';
import '../common/convert.dart';
import '../common/error_handler.dart';
import '../components/create_or_update_label.dart';
import '../screens/wallets_screen.dart';
import '../server/database/transaction_rx.dart';
import '../model/wallet.dart';
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
    amount: -1,
    fee: 0,
    balance: 0,
    balanceFixed: 0,
    categoryId: '',
    date: now,
    walletFromId: '',
    walletToId: '',
    type: TransactionType.expense,
    description: '',
    labels: [],
    externalId: '',
  );
  String title = '${'Create'.i18n} ${'Transaction'.i18n}';
  Action action = Action.create;
  final _showMoreField = ValueNotifier<bool>(false);
  final dateController = TextEditingController(text: '');
  final timeController = TextEditingController(text: '');
  final decimalAmountController = TextEditingController(text: '0');
  final decimalAmountFocusNode = FocusNode();

  final List<PopupMenuItem<TransactionType>> types = TransactionType.values
      .map((t) => PopupMenuItem(
          value: t,
          child: Center(
            child: Text(Convert.capitalize(t.toShortString()), style: TextStyle(color: colorsTypeTransaction[t])),
          )))
      .toList();
  Wallet? walletFromSelected;
  Wallet? walletToSelected;

  InterstitialAd? _interstitialAd;
  String interstitialAdUnitId = '';
  int _interstitialAdRetry = 0;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    decimalAmountFocusNode.addListener(() {
      int? decimal = int.tryParse(decimalAmountController.text);
      if (decimalAmountFocusNode.hasFocus) {
        if (decimal == 0) decimalAmountController.text = '';
      } else {
        if (decimal == null) decimalAmountController.text = '0';
      }
    });
  }

  @override
  void dispose() {
    if (_interstitialAd != null) _interstitialAd!.dispose();
    dateController.dispose();
    timeController.dispose();
    decimalAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadInterstitialAd(String interstitialAdUnitId) {
    return InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          User? user = Provider.of<User>(context, listen: false) as dynamic;
          if (user == null || user.showAds()) setState(() => _interstitialAd = ad);
        },
        onAdFailedToLoad: (err) {
          debugPrint('Failed to load an interstitial ad: ${err.toString()}');
          if (_interstitialAdRetry <= AdStateNotifier.MAXIMUM_NUMBER_OF_AD_REQUEST) {
            debugPrint('=> RETRYING $_interstitialAdRetry load an interstitial ad');
            _interstitialAdRetry++;
            _loadInterstitialAd(interstitialAdUnitId);
          }
        },
      ),
    );
  }

  Future<void> _showInterstitialAd() async {
    if (_interstitialAd == null) return debugPrint('Warning: attempt to show interstitial before loaded.');

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) => debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _loadInterstitialAd(interstitialAdUnitId);
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('ad onAdFailedToShowFullScreenContent: ${error.toString()}');
        ad.dispose();
        _loadInterstitialAd(interstitialAdUnitId);
      },
    );
    return _interstitialAd!.show();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final adState = Provider.of<AdStateNotifier>(context);
    interstitialAdUnitId = adState.interstitialAdUnitId;
    if (_interstitialAd == null) _loadInterstitialAd(interstitialAdUnitId);

    final t = ModalRoute.of(context)!.settings.arguments as Transaction?;
    List<Wallet> wallets = Provider.of<List<Wallet>>(context);
    if (t != null) {
      transaction = t;
      if (t.id != '') {
        walletFromSelected = wallets.firstWhereOrNull((w) => w.id == transaction.walletFromId);
        action = Action.update;
        title = 'Update'.i18n;
      }
    }
    dateController.text = DateFormat('dd/MM/yyyy').format(transaction.date);
    timeController.text = DateFormat('hh:mm').format(transaction.date);
    decimalAmountController.text = transaction.amount.toString().split('.')[1];

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

  Widget buildWallet(BuildContext context, String userId, List<Wallet> wallets, Color disabledColor, bool fromWallet) {
    return Column(
      children: [
        Row(children: [
          Text(
            fromWallet ? 'Choose From Wallet'.i18n : 'Choose To Wallet'.i18n,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => RouteApp.redirect(context: context, url: URLS.createOrUpdateWallet, fromScaffold: false),
          ),
        ]),
        if (wallets.isEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [const SizedBox(height: 60), Text('No wallets by the moment.'.i18n)],
          ),
        if (wallets.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                wallets.length,
                (index) => GestureDetector(
                    onTap: () => setState(() {
                          if (fromWallet) {
                            transaction.walletFromId = wallets[index].id;
                            walletFromSelected = wallets[index];
                          } else {
                            transaction.walletToId = wallets[index].id;
                            walletToSelected = wallets[index];
                          }
                        }),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: WalletItem(
                        wallet: wallets[index],
                        userId: userId,
                        showBalance: false,
                        showActions: false,
                        selected: fromWallet
                            ? transaction.walletFromId == wallets[index].id
                            : transaction.walletToId == wallets[index].id,
                      ),
                    )),
              ),
            ),
          ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget buildAmount() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 3,
          child: Directionality(
            textDirection: ui.TextDirection.rtl, // align errorText to the right
            child: TextFormField(
              initialValue: transaction.amount.isNegative ? '' : transaction.amount.toInt().toString(),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(MAX_LENGTH_AMOUNT)
              ],
              style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '\$0',
                contentPadding: EdgeInsets.only(top: 15),
              ),
              validator: (value) =>
                  value != null && value.isNotEmpty && !int.parse(value).isNegative ? null : 'Is Required'.i18n,
              onChanged: (String _) => _formKey.currentState!.validate(),
              onSaved: (String? value) {
                final decimals = transaction.amount.toString().split('.')[1];
                transaction.amount = double.parse('$value.$decimals');
              },
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: TextFormField(
            controller: decimalAmountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
            textAlign: TextAlign.start,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(border: InputBorder.none, hintText: '00'),
            focusNode: decimalAmountFocusNode,
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
            decoration: InputStyle.inputDecoration(labelTextStr: 'Name'.i18n, hintTextStr: ''),
            validator: (String? value) {
              if (value!.isEmpty) return 'Is Required'.i18n;
              return null;
            },
            onChanged: (String _) => _formKey.currentState!.validate(),
            onSaved: (String? value) => transaction.name = value!,
          ),
        ),
        const SizedBox(width: 5),
        InkWell(
          child: const Icon(Icons.edit_note),
          onTap: () => setState(() => _showMoreField.value = !_showMoreField.value),
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
        decoration: InputStyle.inputDecoration(labelTextStr: 'Description'.i18n, hintTextStr: ''),
        onSaved: (String? value) => transaction.description = value!,
      ),
      const SizedBox(height: 1)
    ]);
  }

  // DATE PICKER //

  Widget buildDateField(ThemeData theme) {
    const formatDate = 'dd/MM/yyyy';
    const formatTime = 'HH:mm';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: InkWell(
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
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.edit_calendar_rounded),
                  const SizedBox(width: 10),
                  Text(DateFormat(formatDate).format(transaction.date), style: theme.textTheme.titleMedium)
                ]),
              ),
            ),
          ),
        ),
        Flexible(
          child: InkWell(
            onTap: () async {
              // Below line stops keyboard from appearing
              FocusScope.of(context).requestFocus(FocusNode());
              // Show Date Picker Here
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                builder: (BuildContext context, Widget? child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                  child: child!,
                ),
                initialTime: TimeOfDay(hour: transaction.date.hour, minute: transaction.date.minute),
              );
              if (picked != null && picked != transaction.getTime()) {
                setState(() {
                  transaction.setTime(hour: picked.hour, minute: picked.minute);
                });
              }
              timeController.text = DateFormat(formatTime).format(transaction.date);
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.more_time_rounded),
                  const SizedBox(width: 10),
                  Text(DateFormat(formatTime).format(transaction.date), style: theme.textTheme.titleMedium)
                ]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget getForm(BuildContext context, List<Wallet> wallets, ThemeData theme) {
    User user = Provider.of<User>(context);
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
                    onSelected: (TransactionType item) {
                      if (action == Action.create) {
                        setState(() => transaction.type = item);
                      } else {
                        HandlerError().setError(
                          'You can\'t update type, please delete the transaction and create a new one.'.i18n,
                        );
                      }
                    },
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
            if (transaction.type == TransactionType.transfer)
              TextFormField(
                initialValue: transaction.fee.toString(),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                decoration:
                    InputStyle.inputDecoration(labelTextStr: 'Fee'.i18n, hintTextStr: '0', prefix: const Text('\$ ')),
                validator: (String? value) => num.tryParse(value ?? '')?.toDouble() == null ? 'Is Required'.i18n : null,
                onSaved: (String? value) => transaction.fee = double.parse(value!),
              ),
            buildWallet(context, user.id, wallets, theme.disabledColor, true),
            if (transaction.type == TransactionType.transfer)
              buildWallet(context, user.id, wallets, theme.disabledColor, false),
            ChooseCategory(
              selected: [transaction.category],
              multi: false,
              onSelected: (c) {
                transaction.category = c;
                transaction.categoryId = c.id;
              },
            ),
            buildName(),
            ValueListenableBuilder(
              valueListenable: _showMoreField,
              builder: (BuildContext context, dynamic show, _) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return SizeTransition(sizeFactor: animation, child: child);
                  },
                  child: show
                      ? CreateOrUpdateLabel(
                          labels: transaction.labels,
                          onSelect: (selection) {
                            if (!transaction.labels.any((l) => l.id == selection.id)) {
                              setState(() => transaction.labels.add(selection));
                            }
                          },
                          onDelete: (label) => setState(
                            () => transaction.labels = transaction.labels.where((l) => l.id != label.id).toList(),
                          ),
                        )
                      : null,
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: _showMoreField,
              builder: (BuildContext context, dynamic show, _) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SizeTransition(sizeFactor: animation, child: child);
                },
                child: show ? buildDescription() : null,
              ),
            ),
            const SizedBox(height: 10),
            buildDateField(theme),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                _formKey.currentState!.save();

                if (transaction.walletFromId == '' || walletFromSelected == null) {
                  return handlerError.setError('You must choice a wallet first.'.i18n);
                }
                if (transaction.type == TransactionType.transfer) {
                  if (transaction.walletToId == '' || walletToSelected == null) {
                    return handlerError.setError('You must choice the wallet of from and to transaction is made.'.i18n);
                  }
                  if (transaction.walletFromId == transaction.walletToId) {
                    return handlerError.setError('Wallet must not be the same.'.i18n);
                  }
                } else {
                  transaction.walletToId = '';
                  transaction.fee = 0.0;
                }
                if (user.defaultCurrency.id == '') {
                  return handlerError.setError('You must have a default currency first.'.i18n);
                }
                if (transaction.categoryId == '') return handlerError.setError('You must choice a category first'.i18n);
                if (transaction.amount <= 0.0) {
                  return handlerError.setError('Amount is required and must be grater than 0.'.i18n);
                }
                Wallet wallet = wallets.firstWhere((w) => w.id == transaction.walletFromId);
                transaction.updateBalance();
                if (user.defaultCurrency.id == wallet.currencyId) {
                  transaction.balanceFixed = transaction.balance;
                } else {
                  CurrencyRate cr = currencyRates.findCurrencyRate(user.defaultCurrency, wallet.currency!);
                  transaction.balanceFixed =
                      cr.convert(transaction.balance, wallet.currencyId, user.defaultCurrency.id);
                }

                if (action == Action.create) {
                  await transactionRx.create(
                      transaction, user.id, walletFromSelected!, currencyRates, walletToSelected);
                } else {
                  await transactionRx.update(
                      transaction, user.id, walletFromSelected!, currencyRates, walletToSelected);
                }
                await _showInterstitialAd();
                Navigator.of(context).pop();
              },
              child: Text(title),
            ),
            const SizedBox(height: 40),
          ]),
        ));
  }
}
