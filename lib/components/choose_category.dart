import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/services.dart';

import '../i18n/index.dart';
import '../common/theme.dart';
import '../common/icon_helper.dart';
import '../components/icon_circle.dart';
import '../components/icon_picker.dart';
import '../server/database/category_rx.dart';
import '../common/error_handler.dart';
import '../common/styles.dart';
import '../model/category.dart';

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

  @override
  void initState() {
    super.initState();
    selectedCategories = List.from(widget.selected);
  }

  bool _notSelected() {
    return selectedCategories.isEmpty || (selectedCategories.isNotEmpty && selectedCategories[0].id == '');
  }

  @override
  Widget build(BuildContext context) {
    List<Category> categories = Provider.of<List<Category>>(context);
    final theme = Theme.of(context);
    selectedCategories = categories.where((c) => selectedCategories.any((select) => select.id == c.id)).toList();

    return Column(
      children: [
        Row(
          children: [
            Text('Choose Category'.i18n, style: theme.textTheme.titleMedium),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => showButtonSheetCreateOrUpdate(context, defaultCategory.copy()),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => Display.message(context, 'Long press on category to edit it.'.i18n, seconds: 4),
            )
          ],
        ),
        if (categories.isNotEmpty && _notSelected())
          OutlinedButton(onPressed: () => openSelect(theme, categories), child: const Text('Select')),
        if (categories.isNotEmpty && !_notSelected())
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [displayCategories(selectedCategories, onTap: (c) => openSelect(theme, categories))],
          ),
        if (categories.isEmpty)
          SizedBox(
            height: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('No categories at the moment..'.i18n)],
            ),
          ),
      ],
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
    var title = temp.id == '' ? '${'Create'.i18n} ${'Category'.i18n}' : '${'Update'.i18n} ${temp.name}';
    var actionButton = temp.id == '' ? 'Create'.i18n : 'Update'.i18n;

    auth.User user = Provider.of<auth.User>(context, listen: false);

    return StatefulBuilder(builder: (context, setState) {
      return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 30, left: 20, right: 20),
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
                    decoration: InputStyle.inputDecoration(labelTextStr: 'Name'.i18n, hintTextStr: ''),
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
                    ElevatedButton(
                      style: ButtonThemeStyle.getStyle(ThemeTypes.warn, context),
                      child: Text('Delete'.i18n),
                      onPressed: () =>
                          categoryRx.delete(temp.id, user.uid).whenComplete(() => Navigator.of(context).pop()),
                    ),
                  buttonCancelContext(context),
                  ElevatedButton(
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

  void openSelect(ThemeData theme, List<Category> categories) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) => BottomSheet(
        enableDrag: false,
        onClosing: () {},
        builder: (BuildContext context) =>
            StatefulBuilder(builder: (BuildContext context, StateSetter setStateBottomSheet) {
          List<Category> db = Provider.of<List<Category>>(context);
          if (db.length != categories.length) categories = db;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (widget.multi ? 'Select Multi Categories' : 'Select Category').i18n,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 30),
                displayCategories(
                  categories,
                  onTap: (selected) => setState(() {
                    if (!widget.multi) {
                      selectedCategories = [selected];
                    } else if (selectedCategories.any((c) => c.id == selected.id)) {
                      selectedCategories = selectedCategories.where((c) => c.id != selected.id).toList();
                    } else {
                      selectedCategories.add(selected);
                    }
                    if (widget.onSelected != null) widget.onSelected!(selected);
                    if (!widget.multi) Navigator.pop(context);
                    setStateBottomSheet(() {});
                  }),
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget displayCategories(List<Category> categories, {required void Function(Category) onTap}) {
    return Align(
      alignment: Alignment.topLeft,
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: List.generate(categories.length, (index) {
          var colorItem = selectedCategories.any((c) => c.id == categories[index].id)
              ? categories[index].color
              : Colors.transparent;
          return GestureDetector(
            onLongPress: () => showButtonSheetCreateOrUpdate(context, categories[index]),
            onTap: () => onTap(categories[index]),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: colorItem),
                borderRadius: categoryBorderRadius,
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconCircle(icon: categories[index].icon, color: categories[index].color),
                    const SizedBox(width: 5),
                    Text(categories[index].name)
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
