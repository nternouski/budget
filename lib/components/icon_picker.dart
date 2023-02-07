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
  var icons = List.from(IconsHelper.list);
  var scrollController = ScrollController();
  var xUnit = 50; // min heigh unit pixels per icon

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      child: IconCircle(
        icon: widget.selected.icon,
        color: widget.color ?? theme.colorScheme.primary,
        size: 42,
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
      return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, top: 30, left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: '',
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    List<IconMap> dummyListData = <IconMap>[];
                    for (var item in IconsHelper.list) {
                      if (item.name.contains(value)) dummyListData.add(item);
                    }
                    setStateBottomSheet(() {
                      icons.clear();
                      icons.addAll(dummyListData);
                    });
                  } else {
                    setStateBottomSheet(() {
                      icons.clear();
                      icons.addAll(List.from(IconsHelper.list));
                    });
                  }
                },
                decoration: InputStyle.inputDecoration(
                  labelTextStr: 'Icon'.i18n,
                  hintTextStr: '${'Icon'.i18n} ${'Name'.i18n}',
                ),
                onSaved: (String? value) {},
              ),
              SizedBox(
                height: icons.isEmpty ? 0 : min(xUnit * (icons.length / 6).ceilToDouble(), xUnit * 5),
                child: Scrollbar(
                  trackVisibility: true,
                  thumbVisibility: true,
                  controller: scrollController,
                  child: GridView.count(
                    crossAxisCount: 7,
                    padding: EdgeInsets.zero,
                    controller: scrollController,
                    children: List.generate(icons.length, (index) {
                      return Center(
                        child: IconButton(
                          padding: const EdgeInsets.all(0),
                          icon: Icon(icons[index].icon, size: 30),
                          onPressed: () => setStateBottomSheet(() {
                            if (widget.onSelected != null) {
                              widget.onSelected!(IconMap(icons[index].name, icons[index].icon));
                            }
                            Navigator.of(context).pop();
                          }),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
