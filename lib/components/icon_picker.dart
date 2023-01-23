import 'dart:math';
import 'package:flutter/material.dart';

import '../i18n/index.dart';
import '../common/icon_helper.dart';
import '../common/styles.dart';

class IconPicker {
  static var icons = <IconMap>[];
  static var scrollController = ScrollController();
  static var xUnit = 50; // min heigh unit pixels per icon

  static picker(IconMap iconMap, Function(IconMap) onIconSelected) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: '',
              onChanged: (value) {
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
                    icons.addAll(IconsHelper.list);
                  });
                }
              },
              decoration: InputStyle.inputDecoration(
                labelTextStr: 'Icon'.i18n,
                hintTextStr: '${'Icon'.i18n} ${'Name'.i18n}',
                suffixIcon: Icon(iconMap.icon, size: 30, color: Colors.grey),
              ),
              onSaved: (String? value) {},
            ),
            SizedBox(
              height: icons.isEmpty ? 0 : min(xUnit * (icons.length / 6).ceilToDouble(), xUnit * 3),
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
                        onPressed: () => setState(() {
                          iconMap = IconMap(icons[index].name, icons[index].icon);
                          onIconSelected(iconMap);
                        }),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ));
      },
    );
  }
}
