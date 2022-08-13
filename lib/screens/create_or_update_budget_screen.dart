import 'package:budget/components/create_or_update_category.dart';
import 'package:budget/components/icon_circle.dart';
import 'package:budget/model/budget.dart';
import 'package:budget/model/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

import '../server/model_rx.dart';
import '../common/styles.dart';

enum Action { create, update }

final now = DateTime.now();

class CreateOrUpdateBudgetScreen extends StatefulWidget {
  late Budget _budget;
  late String title;
  late Action action;

  CreateOrUpdateBudgetScreen({Budget? budget, Key? key}) : super(key: key) {
    if (budget != null) {
      action = Action.update;
      title = 'Update Budget';
      _budget = budget;
    } else {
      action = Action.create;
      title = 'Create Budget';
      _budget = Budget(
        id: '',
        createdAt: DateTime.now(),
        name: 'a',
        color: 'ff00ffff',
        amount: 2,
        balance: 0,
        categories: [],
      );
    }
  }

  @override
  CreateOrUpdateBudgetState createState() => CreateOrUpdateBudgetState(_budget);
}

class CreateOrUpdateBudgetState extends State<CreateOrUpdateBudgetScreen> {
  final Budget budget;

  CreateOrUpdateBudgetState(this.budget);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final sizedBoxHeight = const SizedBox(height: 20);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            titleTextStyle: textTheme.titleLarge,
            pinned: true,
            leading: getBackButton(context),
            title: Text('${widget.title} ${budget.name}'),
          ),
          SliverToBoxAdapter(child: getForm())
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
            labelTextStr: 'Initial Amount',
            hintTextStr: '1300',
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
      validator: (String? value) {
        if (value!.isEmpty) return 'Name is Required.';
        return null;
      },
      onSaved: (String? value) => budget.name = value!,
    );
  }

  Widget buildCategory() {
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

  Widget getForm() {
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
            buildCategory(),
            sizedBoxHeight,
            ElevatedButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                _formKey.currentState!.save();
                widget.action == Action.create ? budgetRx.create(budget) : budgetRx.update(budget);
                Navigator.of(context).pop();
              },
              child: Text(widget.title),
            )
          ]),
        ));
  }
}
