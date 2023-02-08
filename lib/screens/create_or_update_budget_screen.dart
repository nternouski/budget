import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../i18n/index.dart';
import '../common/error_handler.dart';
import '../common/period_stats.dart';
import '../components/interaction_border.dart';
import '../components/choose_category.dart';
import '../model/budget.dart';
import '../server/database/budget_rx.dart';
import '../common/styles.dart';

enum Action { create, update }

final now = DateTime.now();

class CreateOrUpdateBudgetScreen extends StatefulWidget {
  const CreateOrUpdateBudgetScreen({Key? key}) : super(key: key);

  @override
  CreateOrUpdateBudgetState createState() => CreateOrUpdateBudgetState();
}

class CreateOrUpdateBudgetState extends State<CreateOrUpdateBudgetScreen> {
  final handlerError = HandlerError();
  static final List<PeriodStats> periodOptions = [
    PeriodStats(days: 7),
    PeriodStats(days: 14),
    PeriodStats(days: 30),
  ];
  static final minInitialDate = periodOptions.fold<DateTime>(now, (prev, period) {
    var pivote = now.subtract(Duration(days: period.days));
    return pivote.isBefore(prev) ? pivote : prev;
  });

  Budget budget = Budget(
    id: '',
    createdAt: DateTime.now(),
    name: '',
    color: 'ff448aff',
    amount: 2,
    balance: 0,
    categories: [],
    initialDate: now,
    period: periodOptions[0].days,
  );
  String title = '${'Create'.i18n} ${'Budget'.i18n}';
  Action action = Action.create;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController dateController = TextEditingController(text: '');

  final sizedBoxHeight = const SizedBox(height: 20);

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = ModalRoute.of(context)!.settings.arguments as Budget?;
    if (b != null) {
      action = Action.update;
      budget = b;
      title = '${'Update'.i18n} ${budget.name}';
    }
    dateController.text = DateFormat('dd/MM/yyyy').format(budget.initialDate);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: theme.textTheme.titleLarge,
        leading: getBackButton(context),
        title: Text(title),
      ),
      body: CustomScrollView(
        slivers: [SliverToBoxAdapter(child: getForm(context, theme))],
      ),
    );
  }

  Widget buildAmount() {
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Expanded(
        child: TextFormField(
          initialValue: budget.amount.toString(),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
          decoration: InputDecoration(labelText: 'Amount'.i18n, hintText: '0', prefix: const Text('\$ ')),
          validator: (String? value) => (value!.isEmpty) ? 'Is Required'.i18n : null,
          onSaved: (String? value) => budget.amount = double.parse(value!),
        ),
      ),
    ]);
  }

  Widget buildName() {
    return TextFormField(
      initialValue: budget.name,
      decoration: InputDecoration(labelText: 'Name'.i18n, hintText: ''),
      inputFormatters: [LengthLimitingTextInputFormatter(Budget.MAX_LENGTH_NAME)],
      validator: (String? value) => (value!.isEmpty) ? 'Is Required'.i18n : null,
      onSaved: (String? value) => budget.name = value!,
    );
  }

  Widget buildDateField(BuildContext context, ThemeData theme) {
    const formatDate = DateFormat.MONTH_DAY;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Flexible(
          fit: FlexFit.tight,
          child: AppInteractionBorder(
            margin: const EdgeInsets.all(10),
            onTap: () async {
              // Below line stops keyboard from appearing
              FocusScope.of(context).requestFocus(FocusNode());
              // Show Date Picker Here
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: budget.initialDate,
                firstDate: minInitialDate,
                lastDate: now.add(const Duration(days: 30)),
              );
              if (picked != null && picked != budget.initialDate) {
                setState(() => budget.initialDate = picked);
              }
              dateController.text = DateFormat(formatDate).format(budget.initialDate);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.edit_calendar_rounded),
                const SizedBox(width: 10),
                Text(DateFormat(formatDate).format(budget.initialDate), style: theme.textTheme.titleMedium)
              ],
            ),
          ),
        ),
        Flexible(
          child: InputDecorator(
            decoration: InputDecoration(labelText: '  ${'Period'.i18n}'),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isDense: true,
                value: budget.period,
                onChanged: (int? period) => period != null ? setState(() => budget.period = period) : null,
                items: periodOptions
                    .map((o) => DropdownMenuItem(value: o.days, child: Center(child: Text('  ${o.humanize}'))))
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget getForm(BuildContext context, ThemeData theme) {
    auth.User user = Provider.of<auth.User>(context, listen: false);
    return Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(children: <Widget>[
            buildAmount(),
            sizedBoxHeight,
            buildName(),
            ColorPicker(
              color: budget.color,
              width: 35,
              height: 35,
              padding: const EdgeInsets.only(top: 16, bottom: 0),
              borderRadius: 25,
              enableShadesSelection: false,
              onColorChanged: (Color color) => setState(() => budget.color = color),
              pickersEnabled: const {
                ColorPickerType.both: true,
                ColorPickerType.primary: false,
                ColorPickerType.accent: false,
              },
            ),
            ChooseCategory(
              selected: budget.categories,
              multi: true,
              onSelected: (selected) {
                if (budget.categories.any((c) => c.id == selected.id)) {
                  budget.categories = budget.categories.where((c) => c.id != selected.id).toList();
                } else {
                  budget.categories.add(selected);
                }
              },
            ),
            buildDateField(context, theme),
            sizedBoxHeight,
            ElevatedButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                _formKey.currentState!.save();
                if (budget.categories.isEmpty) {
                  return handlerError.showError(context, text: 'You need select at least one category.'.i18n);
                }
                action == Action.create ? budgetRx.create(budget, user.uid) : budgetRx.update(budget, user.uid);
                Navigator.of(context).pop();
              },
              child: Text(title),
            ),
            sizedBoxHeight,
            sizedBoxHeight
          ]),
        ));
  }
}
