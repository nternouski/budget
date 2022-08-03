import 'package:budget/components/create_or_update_category.dart';
import 'package:budget/components/icon_circle.dart';
import 'package:budget/model/budget.dart';
import 'package:budget/model/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

import '../server/model_rx.dart';
import '../common/color_constants.dart';
import '../common/styles.dart';

enum Action { create, update }

class CreateOrUpdateBudgetScreen extends StatefulWidget {
  late Budget _budget;
  late String _title;
  late Action _action;

  CreateOrUpdateBudgetScreen({Budget? budget, Key? key}) : super(key: key) {
    if (budget != null) {
      _action = Action.update;
      _title = 'Update budget';
      _budget = budget;
    } else {
      _action = Action.create;
      _title = 'Create budget';
      _budget = Budget(
        id: '',
        createdAt: DateTime.now(),
        name: 'asdasd',
        color: 'ff00ffff',
        amount: 2222,
        balance: 0,
        categories: [],
      );
    }
  }

  @override
  _CreateOrUpdateBudgetState createState() => _CreateOrUpdateBudgetState(_budget, _title, _action);
}

final now = DateTime.now();

class _CreateOrUpdateBudgetState extends State<CreateOrUpdateBudgetScreen> {
  final Budget budget;
  final String title;
  final Action action;

  _CreateOrUpdateBudgetState(this.budget, this.title, this.action);

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
                        children: [Text('$title ${budget.name}', style: titleStyle)])
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
          initialValue: budget.amount.toString(),
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
                    color: budget.color,
                    width: 40,
                    height: 40,
                    borderRadius: 25,
                    enableShadesSelection: false,
                    onColorChanged: (Color color) => setState(() {
                      budget.color = color;
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
                  color: budget.color,
                  onSelectFocus: false,
                  onSelect: () async => _showDialog(context),
                ),
              ]),
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
                        budgetRx.create(budget);
                      } else {
                        budgetRx.update(budget);
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
