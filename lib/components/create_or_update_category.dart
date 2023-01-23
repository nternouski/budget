import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:provider/provider.dart';

import '../i18n/index.dart';
import '../components/icon_picker.dart';
import '../server/database/category_rx.dart';
import '../common/icon_helper.dart';
import '../common/styles.dart';
import '../model/category.dart';

class CreateOrUpdateCategory {
  static TextEditingController nameController = TextEditingController(text: '');
  static showButtonSheet(context, Category? category) {
    Category c = category ?? defaultCategory;
    nameController.text = c.name;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) => BottomSheet(
        enableDrag: false,
        onClosing: () {},
        builder: (BuildContext context) => _bottomSheet(context, c),
      ),
    );
  }

  static _bottomSheet(BuildContext context, Category category) {
    var title = category.id == '' ? '${'Create'.i18n} ${'Category'.i18n}' : '${'Update'.i18n} ${category.name}';
    var actionButton = category.id == '' ? 'Create'.i18n : 'Update'.i18n;

    auth.User user = Provider.of<auth.User>(context, listen: false);

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return SingleChildScrollView(
            child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 30, left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              TextFormField(
                controller: nameController,
                decoration: InputStyle.inputDecoration(labelTextStr: 'Name'.i18n, hintTextStr: ''),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9  ]')),
                  LengthLimitingTextInputFormatter(Category.MAX_LENGTH_NAME)
                ],
                validator: (String? value) => value!.isEmpty ? '${'Name'.i18n} ${'Is Required'.i18n}.' : null,
              ),
              ColorPicker(
                color: category.color,
                width: 35,
                height: 35,
                padding: const EdgeInsets.only(top: 16, bottom: 0),
                borderRadius: 25,
                enableShadesSelection: false,
                onColorChanged: (Color color) => setState(() => category.color = color),
                pickersEnabled: const {
                  ColorPickerType.both: true,
                  ColorPickerType.primary: false,
                  ColorPickerType.accent: false,
                },
              ),
              IconPicker.picker(
                IconMap(category.iconName, category.icon),
                (iconM) => setState(() {
                  category.iconName = iconM.name;
                  category.icon = iconM.icon;
                }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buttonCancelContext(context),
                  ElevatedButton(
                    child: Text(actionButton),
                    onPressed: () {
                      if (nameController.text.isEmpty) return;
                      if (category.id == '') {
                        categoryRx.create(
                          Category(
                            id: '',
                            name: nameController.text,
                            iconName: category.iconName,
                            color: category.color,
                          ),
                          user.uid,
                        );
                      } else {
                        categoryRx.update(
                          Category(
                            id: category.id,
                            name: nameController.text,
                            iconName: category.iconName,
                            color: category.color,
                          ),
                          user.uid,
                        );
                      }
                      Navigator.pop(context);
                    },
                  ),
                ],
              )
            ],
          ),
        ));
      },
    );
  }
}
