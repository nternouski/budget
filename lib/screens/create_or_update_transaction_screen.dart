// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import '../i18n/index.dart';
import '../common/title_components.dart';
import '../common/ad_helper.dart';
import '../components/choose_category.dart';
import '../model/currency.dart';
import '../model/user.dart';
import '../common/convert.dart';
import '../common/error_handler.dart';
import '../components/interaction_border.dart';
import '../components/create_or_update_label.dart';
import '../screens/wallets_screen.dart';
import '../server/database/transaction_rx.dart';
import '../model/wallet.dart';
import '../model/transaction.dart';
import '../common/styles.dart';
import '../routes.dart';

// ignore: constant_identifier_names
const MAX_LENGTH_AMOUNT = 6;

enum Action { create, update }

class CreateOrUpdateTransactionScreen extends StatefulWidget {
  const CreateOrUpdateTransactionScreen({Key? key}) : super(key: key);

  @override
  CreateOrUpdateTransactionScreenState createState() => CreateOrUpdateTransactionScreenState();
}

final now = DateTime.now();

class SelectedType {
  TransactionType type;
  bool isSelected;
  SelectedType(this.type, this.isSelected);
}

class CreateOrUpdateTransactionScreenState extends State<CreateOrUpdateTransactionScreen> {
  HandlerError handlerError = HandlerError();
  Transaction transaction = Transaction(
    id: '',
    name: '',
    amount: 0,
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

  TitleOfComponent title = TitleOfComponent(action: TitleAction.create, label: 'Transaction'.i18n);
  final _showMoreField = ValueNotifier<bool>(false);
  final dateController = TextEditingController(text: '');
  final timeController = TextEditingController(text: '');
  final amountController = TextEditingController(text: '0');
  final amountFocusNode = FocusNode();
  bool alreadyInit = false;

  final List<PopupMenuItem<TransactionType>> types = TransactionType.values
      .map((t) => PopupMenuItem(
          value: t,
          child: Center(
            child: Text(Convert.capitalize(t.toShortString()).i18n, style: TextStyle(color: colorsTypeTransaction[t])),
          )))
      .toList();
  Wallet? walletFromSelected;
  Wallet? walletToSelected;

  InterstitialAd? _interstitialAd;
  String interstitialAdUnitId = '';
  int _interstitialAdRetry = 0;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FocusNode nameFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    amountFocusNode.addListener(() {
      double? num = double.tryParse(amountController.text);
      if (num != null) {
        amountController.text = num <= 0.0 ? '' : num.toString();
      }
    });
    Future.delayed(const Duration(milliseconds: 1100), () {
      nameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    if (_interstitialAd != null) _interstitialAd!.dispose();
    dateController.dispose();
    timeController.dispose();
    amountController.dispose();
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
    User user = Provider.of<User>(context);

    final adState = Provider.of<AdStateNotifier>(context);
    interstitialAdUnitId = adState.interstitialAdUnitId;
    if (_interstitialAd == null) _loadInterstitialAd(interstitialAdUnitId);

    final t = ModalRoute.of(context)!.settings.arguments as Transaction?;
    List<Wallet> wallets = Provider.of<List<Wallet>>(context);
    if (t != null) {
      transaction = t;
      if (t.id != '') {
        walletFromSelected = wallets.firstWhereOrNull((w) => w.id == transaction.walletFromId);
        title = TitleOfComponent(action: TitleAction.update, label: 'Transaction'.i18n);
      }
      if (!alreadyInit) amountController.text = transaction.amount.toString();
    }
    dateController.text = DateFormat('dd/MM/yyyy').format(transaction.date);
    timeController.text = DateFormat('hh:mm').format(transaction.date);
    alreadyInit = true;

    return Scaffold(
      appBar: AppBar(
        titleTextStyle: theme.textTheme.titleLarge,
        leading: getBackButton(context),
        title: title.getTitle(theme),
        actions: [
          PopupMenuButton<TransactionType>(
            onSelected: (TransactionType item) {
              if (title.createMode()) {
                setState(() => transaction.type = item);
              } else {
                HandlerError().setError(
                  'You can\'t update type, please delete the transaction and create a new one.'.i18n,
                );
              }
            },
            itemBuilder: (BuildContext context) => types,
            child: AppInteractionBorder(
              color: colorsTypeTransaction[transaction.type]?.withOpacity(0.2),
              borderColor: colorsTypeTransaction[transaction.type],
              margin: const EdgeInsets.all(12),
              child: Text(
                Convert.capitalize(transaction.type.toShortString()).i18n,
                style: theme.textTheme.titleMedium!.copyWith(
                  color: colorsTypeTransaction[transaction.type],
                ),
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [SliverToBoxAdapter(child: getForm(context, wallets, user))],
      ),
    );
  }

  Widget buildWallet(
    BuildContext context,
    String userId,
    List<Wallet> wallets,
    TransactionType transactionType,
    StateSetter setStateBottomSheet,
    bool fromWallet,
  ) {
    final theme = Theme.of(context);
    String label = '';
    if (transactionType == TransactionType.transfer) label = '${'Wallet'.i18n} ${fromWallet ? 'From'.i18n : 'To'.i18n}';
    if (transactionType == TransactionType.income) label = 'Add money To'.i18n;
    if (transactionType == TransactionType.expense) label = 'Pay with'.i18n;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          child: Row(children: [Text(label, style: theme.textTheme.titleLarge)]),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            ...wallets
                .map(
                  (wallet) => GestureDetector(
                    onTap: () => setStateBottomSheet(() {
                      if (fromWallet) {
                        transaction.walletFromId = wallet.id;
                        walletFromSelected = wallet;
                      } else {
                        transaction.walletToId = wallet.id;
                        walletToSelected = wallet;
                      }
                    }),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: WalletItem(
                        wallet: wallet,
                        userId: userId,
                        showBalance: false,
                        dense: true,
                        selected:
                            fromWallet ? transaction.walletFromId == wallet.id : transaction.walletToId == wallet.id,
                      ),
                    ),
                  ),
                )
                .toList(),
            TextButton(
              child: Row(children: [const Icon(Icons.add), Text(' ${'Add'.i18n} ${'Wallet'.i18n}')]),
              onPressed: () => RouteApp.redirect(context: context, url: URLS.createOrUpdateWallet, fromScaffold: false),
            ),
          ]),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget buildAmount(ThemeData theme) {
    final intStyle = theme.textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold);
    return TextFormField(
      controller: amountController,
      focusNode: amountFocusNode,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        LengthLimitingTextInputFormatter(MAX_LENGTH_AMOUNT)
      ],
      style: intStyle,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: '\$0',
        hintStyle: intStyle.copyWith(color: theme.hintColor),
        contentPadding: const EdgeInsets.only(top: 15),
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty && double.tryParse(value) != null) {
          return null;
        } else {
          return 'Amount is Required and Grater than 0'.i18n;
        }
      },
      onChanged: (String value) => transaction.amount = double.parse(value),
    );
  }

  Widget buildName(ThemeData theme) {
    final intStyle = theme.textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextFormField(
            initialValue: transaction.name,
            focusNode: nameFocusNode,
            decoration: InputDecoration(
              hintText: 'Name'.i18n,
              hintStyle: intStyle.copyWith(color: theme.hintColor),
            ),
            style: intStyle,
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
        decoration: InputDecoration(labelText: 'Description'.i18n, hintText: ''),
        onSaved: (String? value) => transaction.description = value!,
      ),
      const SizedBox(height: 1)
    ]);
  }

  Widget buildDateField(ThemeData theme, User user) {
    const formatDate = DateFormat.MONTH_DAY;
    const formatTime = 'HH:mm';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: AppInteractionBorder(
            margin: const EdgeInsets.all(10),
            onTap: () async {
              var lastDate = DateTime.now();
              if (user.superUser) lastDate = lastDate.add(const Duration(days: 60));
              // Below line stops keyboard from appearing
              FocusScope.of(context).requestFocus(FocusNode());
              // Show Date Picker Here
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: transaction.date,
                firstDate: DateTime(2010),
                lastDate: lastDate,
              );
              if (picked != null && picked != transaction.date) {
                setState(() {
                  transaction.date = picked.copyWith(
                    hour: transaction.date.hour,
                    minute: transaction.date.minute,
                    second: transaction.date.second,
                  );
                });
              }
              dateController.text = DateFormat(formatDate).format(transaction.date);
            },
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.edit_calendar_rounded),
              const SizedBox(width: 10),
              Text(DateFormat(formatDate).format(transaction.date), style: theme.textTheme.titleMedium)
            ]),
          ),
        ),
        const SizedBox(width: 15),
        Flexible(
          child: AppInteractionBorder(
            margin: const EdgeInsets.all(10),
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
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.more_time_rounded),
              const SizedBox(width: 10),
              Text(DateFormat(formatTime).format(transaction.date), style: theme.textTheme.titleMedium)
            ]),
          ),
        ),
      ],
    );
  }

  _bottomSheet(
    BuildContext rootContext,
    ThemeData theme,
    User user,
    List<Wallet> wallets,
    List<CurrencyRate> currencyRates,
  ) {
    return StatefulBuilder(
      builder: (BuildContext contextStateFull, StateSetter setStateBottomSheet) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(contextStateFull).viewInsets.bottom + 20, top: 10, left: 20, right: 20),
            child: Column(children: [
              buildWallet(rootContext, user.id, wallets, transaction.type, setStateBottomSheet, true),
              if (transaction.type == TransactionType.transfer)
                buildWallet(rootContext, user.id, wallets, transaction.type, setStateBottomSheet, false),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 5,
                    child: Text(walletFromSelected?.currency?.symbol ?? '    ', style: theme.textTheme.titleMedium),
                  ),
                  Flexible(flex: 5, child: buildAmount(theme)),
                  FilledButton(
                    onPressed: () => onSubmit(rootContext, wallets, user, currencyRates),
                    child: title.getButton(),
                  ),
                ],
              ),
            ]),
          ),
        );
      },
    );
  }

  void onSubmit(BuildContext rootContext, List<Wallet> wallets, User user, List<CurrencyRate> currencyRates) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (transaction.walletFromId == '' || walletFromSelected == null) {
      return handlerError.showError(rootContext, text: 'You must choice a wallet first.'.i18n);
    }
    if (transaction.type == TransactionType.transfer) {
      if (transaction.walletToId == '' || walletToSelected == null) {
        return handlerError.showError(rootContext,
            text: 'You must choice the wallet of from and to transaction is made.'.i18n);
      }
      if (transaction.walletFromId == transaction.walletToId) {
        return handlerError.showError(rootContext, text: 'Wallet must not be the same.'.i18n);
      }
    } else {
      transaction.walletToId = '';
      transaction.fee = 0.0;
    }
    if (user.defaultCurrency.id == '') {
      return handlerError.showError(rootContext, text: 'You must have a default currency first.'.i18n);
    }
    if (transaction.amount <= 0.0) {
      return handlerError.showError(rootContext, text: 'Amount is required and must be grater than 0.'.i18n);
    }
    Wallet wallet = wallets.firstWhere((w) => w.id == transaction.walletFromId);
    transaction.updateBalance();
    if (user.defaultCurrency.id == wallet.currencyId) {
      transaction.balanceFixed = transaction.balance;
    } else {
      CurrencyRate cr = currencyRates.findCurrencyRate(user.defaultCurrency, wallet.currency!);
      transaction.balanceFixed = cr.convert(transaction.balance, wallet.currencyId, user.defaultCurrency.id);
    }

    if (title.createMode()) {
      await transactionRx.create(transaction, user.id, walletFromSelected!, currencyRates, walletToSelected);
    } else {
      await transactionRx.update(transaction, user.id, walletFromSelected!, currencyRates, walletToSelected);
    }
    try {
      await _showInterstitialAd();
    } catch (e) {
      handlerError.showError(rootContext, text: e.toString());
    }
    Navigator.of(rootContext).pop();
    Navigator.of(rootContext).pop();
  }

  Widget getForm(BuildContext rootContext, List<Wallet> wallets, User user) {
    final theme = Theme.of(rootContext);
    List<CurrencyRate> currencyRates = Provider.of<List<CurrencyRate>>(rootContext);

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(children: <Widget>[
          buildName(theme),
          if (transaction.type == TransactionType.transfer)
            TextFormField(
              initialValue: transaction.fee.toString(),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              decoration: InputDecoration(labelText: 'Fee'.i18n, hintText: '0', prefix: const Text('\$ ')),
              validator: (String? value) => num.tryParse(value ?? '')?.toDouble() == null ? 'Is Required'.i18n : null,
              onSaved: (String? value) => transaction.fee = double.parse(value!),
            ),
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
          ChooseCategory(
            selected: [transaction.category],
            multi: false,
            onSelected: (c) {
              FocusManager.instance.primaryFocus?.unfocus();
              transaction.category = c;
              transaction.categoryId = c.id;
            },
          ),
          const SizedBox(height: 10),
          buildDateField(theme, user),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  _formKey.currentState!.save();
                  if (transaction.categoryId == '') {
                    return handlerError.showError(rootContext, text: 'You must choice a category first.'.i18n);
                  }
                  await showModalBottomSheet(
                    context: rootContext,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    builder: (BuildContext context) => BottomSheet(
                      enableDrag: false,
                      onClosing: () {},
                      builder: (BuildContext _) => _bottomSheet(rootContext, theme, user, wallets, currencyRates),
                    ),
                  );
                },
                child: Text('Next Step'.i18n, style: theme.textTheme.labelLarge!.copyWith(color: Colors.white)),
              ),
            ],
          )
        ]),
      ),
    );
  }
}
