import 'dart:developer';

import 'package:budget/common/period_stats.dart';
import 'package:budget/model/transaction.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/services.dart';

import '../i18n/index.dart';
import '../common/theme.dart';
import '../common/icon_helper.dart';
import '../components/interaction_border.dart';
import '../components/icon_circle.dart';
import '../components/icon_picker.dart';
import '../server/database/category_rx.dart';
import '../common/error_handler.dart';
import '../common/styles.dart';
import '../model/category.dart';

class CategoryGroup {
  List<Category> toDisplay = List.from([]);
  List<Category> toHide = List.from([]);

  CategoryGroup();
}

class ChooseCategory extends StatefulWidget {
  final List<Category> selected;
  final bool multi;
  final void Function(Category)? onSelected;

  const ChooseCategory({
    Key? key,
    required this.selected,
    required this.multi,
    this.onSelected,
  }) : super(key: key);

  @override
  ChooseCategoryState createState() => ChooseCategoryState();
}

class ChooseCategoryState extends State<ChooseCategory> {
  late List<Category> selectedCategories;

  bool showHiddenCategories = false;
  @override
  void initState() {
    super.initState();
    selectedCategories = List.from(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    List<Category> categories = Provider.of<List<Category>>(context);
    selectedCategories = categories.where((c) => selectedCategories.any((select) => select.id == c.id)).toList();

    ThemeData theme = Theme.of(context);
    List<Transaction> transactions = Provider.of<List<Transaction>>(context);
    List<Category> db = Provider.of<List<Category>>(context);
    if (db.length != categories.length) categories = db;

    return ValueListenableBuilder<PeriodStats>(
      valueListenable: periods.selected,
      builder: (context, periodStats, child) {
        final CategoryGroup group = CategoryGroup();
        final DateTime now = DateTime.now();
        final periodTime = now.subtract(Duration(days: periodStats.days));
        for (var c in categories) {
          final isUsed = transactions.any((t) => periodTime.isBefore(t.createdAt) && t.categoryId == c.id);
          final isCreatedToday = now.subtract(const Duration(days: 1)).isBefore(c.createdAt);
          if (isUsed || isCreatedToday) {
            group.toDisplay.add(c);
          } else {
            group.toHide.add(c);
          }
        }
        return Card(
          margin: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 10),
                    child: Text(
                      (widget.multi ? 'Select Multi Categories' : 'Select Category').i18n,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => Display.message(context, 'Long press on category to edit it.'.i18n, seconds: 4),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_rounded),
                    onPressed: () => showButtonSheetCreateOrUpdate(context, defaultCategory.copy()),
                  ),
                ],
              ),
              Padding(padding: const EdgeInsets.only(left: 15), child: displayCategories(context, group.toDisplay)),
              InkWell(
                borderRadius: borderRadiusApp,
                onTap: () => setState(() => showHiddenCategories = !showHiddenCategories),
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, top: 7, bottom: 7),
                  child: Row(
                    children: [
                      Icon(showHiddenCategories ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_down),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text('Hidden Categories'.i18n, style: Theme.of(context).textTheme.labelMedium),
                      ),
                    ],
                  ),
                ),
              ),
              if (showHiddenCategories) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 10),
                  child: displayCategories(context, group.toHide),
                ),
                const SizedBox(height: 15),
              ],
            ],
          ),
        );
      },
    );
  }

  Future showButtonSheetCreateOrUpdate(context, Category category) {
    var temp = category.copy();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) => BottomSheet(
        enableDrag: false,
        onClosing: () {},
        builder: (BuildContext context) => _bottomSheetCreateOrUpdate(context, category, temp),
      ),
    );
  }

  _bottomSheetCreateOrUpdate(BuildContext context, Category original, Category temp) {
    var title = temp.id == '' ? '${'Create'.i18n} ${'Category'.i18n}' : '${'Save'.i18n} ${temp.name}';
    var actionButton = temp.id == '' ? 'Create'.i18n : 'Save'.i18n;

    auth.User user = Provider.of<auth.User>(context, listen: false);

    return StatefulBuilder(builder: (context, setState) {
      return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, top: 30, left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                IconPicker(
                  selected: IconMap(temp.iconName, temp.icon),
                  color: temp.color,
                  onSelected: (iconM) => setState(() {
                    temp.iconName = iconM.name;
                    temp.icon = iconM.icon;
                  }),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: TextFormField(
                    initialValue: temp.name,
                    decoration: InputDecoration(labelText: 'Name'.i18n, hintText: ''),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9  ]')),
                      LengthLimitingTextInputFormatter(Category.MAX_LENGTH_NAME)
                    ],
                    onChanged: (value) => value.isEmpty ? null : temp.name = value,
                    validator: (String? value) => value!.isEmpty ? '${'Name'.i18n} ${'Is Required'.i18n}.' : null,
                  ),
                ),
              ]),
              ColorPicker(
                color: temp.color,
                width: 35,
                height: 35,
                padding: const EdgeInsets.only(top: 16, bottom: 0),
                borderRadius: 25,
                enableShadesSelection: false,
                onColorChanged: (Color color) => setState(() => temp.color = color),
                pickersEnabled: const {
                  ColorPickerType.both: true,
                  ColorPickerType.primary: false,
                  ColorPickerType.accent: false,
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (temp.id != '')
                    FilledButton(
                      style: ButtonThemeStyle.getStyle(ThemeTypes.warn, context),
                      child: Text('Delete'.i18n),
                      onPressed: () =>
                          categoryRx.delete(temp.id, user.uid).whenComplete(() => Navigator.of(context).pop()),
                    ),
                  getButtonCancelContext(context),
                  FilledButton(
                    child: Text(actionButton),
                    onPressed: () {
                      if (temp.name.isEmpty) return;
                      if (temp.id == '') {
                        categoryRx.create(temp.copy(id: ''), user.uid);
                      } else {
                        categoryRx.update(temp, user.uid);
                        original.setFrom(temp);
                      }
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
    });
  }

  Widget displayCategories(BuildContext context, List<Category> categories) {
    return Align(
      alignment: Alignment.topLeft,
      child: Wrap(
        spacing: 1,
        runSpacing: 1,
        children: [
          ...List.generate(categories.length, (index) {
            final selected = categories[index];
            var colorItem = selectedCategories.any((c) => c.id == categories[index].id)
                ? categories[index].color
                : Colors.transparent;
            return AppInteractionBorder(
              borderColor: colorItem,
              margin: const EdgeInsets.only(right: 8),
              onLongPress: () => showButtonSheetCreateOrUpdate(context, categories[index]),
              onTap: () => setState(() {
                if (!widget.multi) {
                  selectedCategories = [selected];
                } else if (selectedCategories.any((c) => c.id == selected.id)) {
                  selectedCategories = selectedCategories.where((c) => c.id != selected.id).toList();
                } else {
                  selectedCategories.add(selected);
                }
                if (widget.onSelected != null) widget.onSelected!(selected);
                setState(() {});
              }),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconCircle(icon: categories[index].icon, color: categories[index].color),
                  const SizedBox(width: 8),
                  Text(
                    categories[index].name,
                    style: TextStyle(color: categories[index].color),
                  )
                ],
              ),
            );
          })
        ],
      ),
    );
  }
}
