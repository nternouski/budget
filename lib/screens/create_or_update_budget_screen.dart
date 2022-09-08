import 'package:budget/components/create_or_update_category.dart';
import 'package:budget/components/icon_circle.dart';
import 'package:budget/model/budget.dart';
import 'package:budget/model/category.dart';
import 'package:budget/server/database/budget_rx.dart';
import 'package:budget/server/database/category_rx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../common/styles.dart';

enum Action { create, update }

final now = DateTime.now();

class CreateOrUpdateBudgetScreen extends StatefulWidget {
  const CreateOrUpdateBudgetScreen({Key? key}) : super(key: key);

  @override
  CreateOrUpdateBudgetState createState() => CreateOrUpdateBudgetState();
}

class CreateOrUpdateBudgetState extends State<CreateOrUpdateBudgetScreen> {
  Budget budget = Budget(
    id: '',
    createdAt: DateTime.now(),
    name: '',
    color: 'ff00ffff',
    amount: 2,
    balance: 0,
    categories: [],
  );
  String title = 'Create Budget';
  Action action = Action.create;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final sizedBoxHeight = const SizedBox(height: 20);

  @override
  Widget build(BuildContext context) {
    final b = ModalRoute.of(context)!.settings.arguments as Budget?;
    if (b != null) {
      action = Action.update;
      title = 'Update Budget';
      budget = b;
    }
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            titleTextStyle: textTheme.titleLarge,
            pinned: true,
            leading: getBackButton(context),
            title: Text('$title ${budget.name}'),
          ),
          SliverToBoxAdapter(child: getForm(context))
        ],
      ),
    );
  }

  Widget buildAmount() {
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Expanded(
        child: TextFormField(
          initialValue: budget.amount.toString(),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.]'))],
          decoration: InputStyle.inputDecoration(
            labelTextStr: 'Budget Amount',
            hintTextStr: '0',
            prefix: const Text('\$ '),
          ),
          validator: (String? value) {
            if (value!.isEmpty) return 'Amount is Required.';
            return null;
          },
          onSaved: (String? value) => budget.amount = double.parse(value!),
        ),
      ),
    ]);
  }

  Widget buildName() {
    return TextFormField(
      initialValue: budget.name,
      decoration: InputStyle.inputDecoration(labelTextStr: 'Budget Name', hintTextStr: 'Bank'),
      inputFormatters: [LengthLimitingTextInputFormatter(Budget.MAX_LENGTH_NAME)],
      validator: (String? value) {
        if (value!.isEmpty) return 'Name is Required.';
        return null;
      },
      onSaved: (String? value) => budget.name = value!,
    );
  }

  Widget buildCategory(BuildContext context, String userId) {
    List<Category> categories = Provider.of<List<Category>>(context);
    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Choose Category',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
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
                var colorItem = budget.categories.any((c) => c.id == categories[index].id)
                    ? categories[index].color
                    : Colors.transparent;
                return GestureDetector(
                  onLongPress: () => CreateOrUpdateCategory.showButtonSheet(context, categories[index]),
                  onTap: () => setState(() {
                    if (budget.categories.any((c) => c.id == categories[index].id)) {
                      budget.categories = budget.categories.where((c) => c.id != categories[index].id).toList();
                    } else {
                      budget.categories.add(categories[index]);
                    }
                  }),
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
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16))
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        const SizedBox(height: 10),
        const Text('Long press for edit category.'),
        sizedBoxHeight,
      ],
    );
  }

  Widget getForm(BuildContext context) {
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
              width: 40,
              height: 40,
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
            buildCategory(context, user.uid),
            sizedBoxHeight,
            ElevatedButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                _formKey.currentState!.save();
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
