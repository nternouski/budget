import 'package:flutter/material.dart';

import '../common/icon_helper.dart';
import '../common/styles.dart';

class IconPicker {
  static var icons = <IconMap>[];
  static picker(IconMap iconMap, Function(IconMap) onIconSelected) {
    const sizedBoxHeight = SizedBox(height: 10);

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
                labelTextStr: 'Icon',
                hintTextStr: 'Icon Name',
                suffixIcon: Icon(iconMap.icon, size: 30, color: Colors.grey),
              ),
              onSaved: (String? value) {},
            ),
            sizedBoxHeight,
            SizedBox(
              height: icons.isEmpty ? 10 : 200,
              child: GridView.count(
                crossAxisCount: 6,
                children: List.generate(icons.length, (index) {
                  return Center(
                    child: IconButton(
                      icon: Icon(icons[index].icon),
                      onPressed: () => setState(() {
                        iconMap = IconMap(icons[index].name, icons[index].icon);
                        onIconSelected(iconMap);
                      }),
                    ),
                  );
                }),
              ),
            ),
          ],
        ));
      },
    );
  }
}
