import 'dart:math';
import 'package:flutter/material.dart';

import '../i18n/index.dart';
import '../common/icon_helper.dart';
import '../common/styles.dart';
import '../components/icon_circle.dart';

class IconPicker extends StatefulWidget {
  final IconMap selected;
  final Color? color;
  final void Function(IconMap)? onSelected;

  const IconPicker({Key? key, required this.selected, this.color, this.onSelected}) : super(key: key);

  @override
  IconPickerState createState() => IconPickerState();
}

class IconPickerState extends State<IconPicker> {
  List<IconMap> icons = List.from(IconsHelper.list);
  ScrollController scrollCtr = ScrollController();

  final int xUnit = 50; // min heigh unit pixels per icon
  final double maxVisibleRows = 6;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      child: IconCircle(
        icon: widget.selected.icon,
        color: widget.color ?? theme.colorScheme.primary,
        size: 40,
        withBorder: true,
      ),
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (BuildContext context) => BottomSheet(
          enableDrag: false,
          onClosing: () {},
          builder: (BuildContext context) => _bottomSheetCreateOrUpdate(context),
        ),
      ),
    );
  }

  _bottomSheetCreateOrUpdate(BuildContext context) {
    return StatefulBuilder(builder: (context, setStateBottomSheet) {
      // grid of icons
      var grid = GridView.count(
        crossAxisCount: 7,
        padding: EdgeInsets.zero,
        controller: scrollCtr,
        children: List.generate(
          icons.length,
          (index) => Center(
            child: IconButton(
              padding: const EdgeInsets.all(0),
              icon: Icon(icons[index].icon, size: 30),
              onPressed: () => setStateBottomSheet(() => _onSelect(icons[index])),
            ),
          ),
        ),
      );

      return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, top: 30, left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: '',
                onChanged: (value) => _onInputChange(setStateBottomSheet, value),
                decoration: InputDecoration(labelText: 'Icon'.i18n, hintText: '${'Icon'.i18n} ${'Name'.i18n}'),
              ),
              SizedBox(
                height: icons.isEmpty ? 0 : min(xUnit * (icons.length / 7).ceilToDouble(), xUnit * maxVisibleRows),
                child: Scrollbar(trackVisibility: true, thumbVisibility: true, controller: scrollCtr, child: grid),
              ),
            ],
          ),
        ),
      );
    });
  }

  _onSelect(IconMap icon) {
    if (widget.onSelected != null) widget.onSelected!(IconMap(icon.name, icon.icon));
    Navigator.of(context).pop();
  }

  _onInputChange(StateSetter setState, String value) {
    if (value.isNotEmpty) {
      List<IconMap> dummyListData = <IconMap>[];
      for (var item in IconsHelper.list) {
        if (item.name.contains(value)) dummyListData.add(item);
      }
      setState(() {
        icons.clear();
        icons.addAll(dummyListData);
      });
    } else {
      setState(() {
        icons.clear();
        icons.addAll(List.from(IconsHelper.list));
      });
    }
  }
}
