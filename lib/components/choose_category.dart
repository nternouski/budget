import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/create_or_update_category.dart';
import '../components/icon_circle.dart';
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
    return selectedCategories.isEmpty || (selectedCategories[0] != null && selectedCategories[0].id == '');
  }

  @override
  Widget build(BuildContext context) {
    List<Category> categories = Provider.of<List<Category>>(context);
    final theme = Theme.of(context);

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
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => Display.message(context, 'Long press on category to edit it.', seconds: 4),
            )
          ],
        ),
        if (categories.isNotEmpty && _notSelected())
          TextButton(onPressed: () => openSelect(theme, categories), child: const Text('Select')),
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
              children: const [Text('No categories by the moment.')],
            ),
          ),
      ],
    );
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
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Category', style: theme.textTheme.titleLarge),
                const SizedBox(height: 30),
                displayCategories(
                  categories,
                  onTap: (selected) => setState(() {
                    if (!widget.multi) {
                      selectedCategories[0] = selected;
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
            onLongPress: () => CreateOrUpdateCategory.showButtonSheet(context, categories[index]),
            onTap: () => onTap(categories[index]),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: colorItem),
                borderRadius: categoryBorderRadius,
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconCircle(icon: categories[index].icon, color: categories[index].color),
                    const SizedBox(width: 5),
                    Text(categories[index].name, style: const TextStyle(fontWeight: FontWeight.w500))
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
