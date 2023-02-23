import 'dart:math';
import 'package:budget/components/expense_prediction_widget.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import '../i18n/index.dart';
import '../common/styles.dart';
import '../model/user.dart';
import '../model/currency.dart';
import '../model/expense_prediction.dart';
import '../components/select_currency.dart';
import '../components/background_dismissible.dart';
import '../server/database/expense_prediction_rx.dart';

class ExpensePredictionScreenState extends StatefulWidget {
  const ExpensePredictionScreenState({Key? key}) : super(key: key);

  @override
  State createState() => _ExpensePredictionScreenState();
}

class _ExpensePredictionScreenState extends State<ExpensePredictionScreenState> {
  static String defaultPredictionId = '';

  int period = 30;
  String userId = '';
  bool docChanged = false;
  bool init = true;
  var prediction = ExpensePrediction<ExpensePredictionGroupTotal>(id: defaultPredictionId, name: '', groups: []);

  final ScrollController _scrollController = ScrollController();
  var _updateItem = ExpensePredictionItem(name: '', amount: 0, days: 7, check: true);

  @override
  Future<void> dispose() async {
    Future.delayed(Duration.zero, () async {
      if (!docChanged) return;
      if (prediction.id == defaultPredictionId) {
        await expensePredictionRx.create(prediction, userId);
      } else {
        await expensePredictionRx.update(prediction, userId);
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final temp = Provider.of<List<ExpensePrediction>>(context);

    User user = Provider.of<User>(context);
    userId = user.id;

    if (temp.isNotEmpty && init) {
      init = false;
      List<Currency> currencies = List.from(Provider.of<List<Currency>>(context));

      var currencyId = temp[0].currencyId == '' ? user.defaultCurrency.id : temp[0].currencyId;
      prediction = ExpensePrediction<ExpensePredictionGroupTotal>(
        id: temp[0].id,
        name: temp[0].name,
        currencyId: currencyId,
        currency: currencies.firstWhereOrNull((c) => c.id == currencyId),
        groups: temp[0].groups.map((g) => ExpensePredictionGroupTotal.fromExpensePredictionGroup(g, period)).toList(),
        createdAt: temp[0].createdAt,
      );
    }
    if (prediction.groups.isEmpty) {
      prediction.groups.add(
        ExpensePredictionGroupTotal(name: 'List'.i18n, items: [], check: true, collapse: false, period: period),
      );
    }

    double total = prediction.groups.fold(0.0, (acc, g) => acc + g.updateTotal(period));

    return Scaffold(
      appBar: AppBar(
        titleTextStyle: theme.textTheme.titleLarge,
        leading: getBackButton(context),
        title: Text('Expense Simulation'.i18n),
        actions: [
          SelectCurrencyFormField(
            key: Key(Random().nextDouble().toString()),
            initialValue: prediction.currency,
            topPadding: 0,
            onChange: (selected) {
              docChanged = true;
              if (selected != null) {
                setState(() {
                  prediction.currencyId = selected.id;
                  prediction.currency = selected;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_calendar),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              builder: (BuildContext context) => BottomSheet(
                enableDrag: false,
                onClosing: () {},
                builder: (BuildContext context) => _bottomSheetPeriod(context),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            sliver: DragAndDropLists(
              children: List.generate(prediction.groups.length, (index) => _getListGroup(context, theme, index)),
              sliverList: true,
              scrollController: _scrollController,
              onItemReorder: _onItemReorder,
              onListReorder: _onListReorder,
              itemDecorationWhileDragging: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.all(Radius.circular(6)),
              ),
              listInnerDecoration: BoxDecoration(
                color: theme.canvasColor,
                borderRadius: const BorderRadius.all(Radius.circular(6)),
              ),
              lastItemTargetHeight: 0,
              lastListTargetSize: 0,
              listDragHandle: DragHandle(
                verticalAlignment: DragHandleVerticalAlignment.top,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, right: 10),
                  child: Icon(Icons.menu, color: theme.hintColor),
                ),
              ),
              itemDragHandle: DragHandle(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.menu, color: theme.hintColor),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 5),
                Divider(thickness: 1, color: theme.colorScheme.primary),
                Padding(
                  padding: const EdgeInsets.only(top: 15, right: 50, bottom: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      total.prettierToText(withSymbol: true, prefix: 'TOTAL ', style: theme.textTheme.titleLarge),
                      Text('in %d days '.plural(period)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          var group = ExpensePredictionGroupTotal(name: '', items: [], check: true, collapse: false, period: period);
          return showModalBottomSheet(
            enableDrag: true,
            context: context,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            builder: (BuildContext context) => BottomSheet(
              enableDrag: false,
              onClosing: () {},
              builder: (BuildContext context) => _bottomSheetGroup(theme, group),
            ),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        label: Text('Add'.i18n),
        isExtended: true,
        icon: const Icon(Icons.add, size: 25),
      ),
    );
  }

  DragAndDropList _getListGroup(BuildContext context, ThemeData theme, int index) {
    ExpensePredictionGroupTotal group = prediction.groups[index];

    var items = List.generate(group.items.length, (index) {
      return DragAndDropItem(
        canDrag: group.items[index].check,
        child: Dismissible(
          key: UniqueKey(),
          onDismissed: (direction) => setState(() => group.items.removeAt(index)),
          background: const BackgroundDeleteDismissible(padding: EdgeInsets.only(right: 30)),
          direction: DismissDirection.endToStart,
          child: InkWell(
            child: ItemWidget(item: group.items[index]),
            onTap: () => setState(() {
              docChanged = true;
              group.items[index].check = !group.items[index].check;
            }),
            onLongPress: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              builder: (BuildContext context) {
                _updateItem = group.items[index];
                return BottomSheet(
                  enableDrag: false,
                  onClosing: () {},
                  builder: (_) => _bottomSheetItem(theme, group, index),
                );
              },
            ),
          ),
        ),
      );
    }).toList();

    items.add(DragAndDropItem(
      canDrag: false,
      child: ElevatedButton(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${'Create'.i18n} ${'Item'.i18n}',
                style: theme.textTheme.titleMedium!.copyWith(color: theme.colorScheme.primary),
              )
            ],
          ),
        ),
        onPressed: () async {
          _updateItem = _updateItem.copyWith(name: '', amount: 0.0, days: 7, check: true);
          return showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            builder: (BuildContext context) => BottomSheet(
              enableDrag: false,
              onClosing: () {},
              builder: (BuildContext context) => _bottomSheetItem(theme, group, -1),
            ),
          );
        },
      ),
    ));

    Widget contentsWhenEmpty = Padding(padding: const EdgeInsets.all(20), child: Text('Empty List'.i18n));
    if (group.collapse) contentsWhenEmpty = const SizedBox();

    return DragAndDropList(
      contentsWhenEmpty: contentsWhenEmpty,
      header: Padding(
        padding: const EdgeInsets.only(right: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() {
                    docChanged = true;
                    group.collapse = !group.collapse;
                  }),
                  icon: Icon(group.collapse ? Icons.keyboard_arrow_right : Icons.keyboard_arrow_down, size: 20),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Text(group.name, style: theme.textTheme.titleMedium, overflow: TextOverflow.ellipsis),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 22),
                  onPressed: () => showModalBottomSheet(
                    enableDrag: true,
                    context: context,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    builder: (BuildContext context) => BottomSheet(
                      enableDrag: false,
                      onClosing: () {},
                      builder: (BuildContext context) => _bottomSheetGroup(theme, group, create: false),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever, size: 22),
                  onPressed: () => setState(() => prediction.groups.removeAt(index)),
                ),
              ],
            ),
          ],
        ),
      ),
      children: group.collapse ? [] : items,
      footer: Padding(
        padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            group.total.prettierToText(withSymbol: true, prefix: 'Total: ', style: theme.textTheme.titleMedium),
            const SizedBox(width: 30)
          ],
        ),
      ),
    );
  }

  _onItemReorder(int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    docChanged = true;
    setState(() {
      var movedItem = prediction.groups[oldListIndex].items.removeAt(oldItemIndex);
      prediction.groups[newListIndex].items.insert(newItemIndex, movedItem);
    });
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    docChanged = true;
    setState(() {
      var movedList = prediction.groups.removeAt(oldListIndex);
      prediction.groups.insert(newListIndex, movedList);
    });
  }

  _bottomSheetItem(ThemeData theme, ExpensePredictionGroupTotal group, int index) {
    docChanged = true;
    const sizedBoxHeight = SizedBox(height: 20);
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, top: 30, left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              '${index == -1 ? 'Create'.i18n : 'Update'.i18n} ${'Item'.i18n}',
              style: theme.textTheme.titleLarge,
            ),
            TextFormField(
              initialValue: _updateItem.name,
              autofocus: true,
              decoration: InputDecoration(labelText: 'Name'.i18n, hintText: ''),
              inputFormatters: [LengthLimitingTextInputFormatter(25)],
              validator: (String? value) => value!.isEmpty ? '${'Name'.i18n} ${'Is Required'.i18n}' : null,
              onChanged: (String name) => _updateItem.name = name,
            ),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                child: TextFormField(
                  initialValue: _updateItem.amount.toString(),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  decoration: InputDecoration(labelText: 'Amount'.i18n, hintText: '0', prefix: const Text('\$ ')),
                  validator: (String? value) => value!.isEmpty ? 'Is Required'.i18n : null,
                  onChanged: (String value) => _updateItem.amount = double.parse(value != '' ? value : '0'),
                ),
              ),
              Expanded(
                child: TextFormField(
                  initialValue: _updateItem.days.toString(),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  decoration: InputDecoration(labelText: 'Durations (Days)'.i18n, hintText: '0'),
                  validator: (String? value) => value!.isEmpty ? 'Is Required'.i18n : null,
                  onChanged: (String value) => _updateItem.days = int.parse(value != '' ? value : '0'),
                ),
              ),
            ]),
            sizedBoxHeight,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                getButtonCancelContext(context),
                FilledButton(
                  child: Text(index == -1 ? 'Create'.i18n : 'Update'.i18n),
                  onPressed: () {
                    if (index == -1) group.items.add(_updateItem.copyWith());
                    setState(() {});
                    Navigator.pop(context);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  _bottomSheetGroup(ThemeData theme, ExpensePredictionGroupTotal group, {bool create = true}) {
    docChanged = true;
    const sizedBoxHeight = SizedBox(height: 20);

    return SingleChildScrollView(
        child: Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, top: 30, left: 20, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${create ? 'Create'.i18n : 'Update'.i18n} ${'Group'.i18n}',
            style: theme.textTheme.titleLarge,
          ),
          TextFormField(
            autofocus: true,
            initialValue: group.name,
            decoration: InputDecoration(labelText: 'Name'.i18n, hintText: ''),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z1-9  ]')),
              LengthLimitingTextInputFormatter(25)
            ],
            validator: (String? value) => value!.isEmpty ? '${'Name'.i18n} ${'Is Required'.i18n}' : null,
            onChanged: (String name) => group.name = name,
          ),
          sizedBoxHeight,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              getButtonCancelContext(context),
              FilledButton(
                child: Text(create ? 'Create'.i18n : 'Update'.i18n),
                onPressed: () {
                  if (create) prediction.groups.add(group.copyWith(period: period));
                  setState(() {});
                  Navigator.pop(context);
                },
              ),
            ],
          )
        ],
      ),
    ));
  }

  _bottomSheetPeriod(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, top: 30, left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Period of Time'.i18n, style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            ...[7, 14, 30].map(
              (day) => CheckboxListTile(
                title: Text('%d days'.plural(day)),
                value: period == day,
                onChanged: (check) {
                  setState(() => period = day);
                  Navigator.pop(context);
                },
                selected: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
