import 'package:flutter/material.dart';

import '../i18n/index.dart';

class TextColor {
  static Color getContrastOf(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}

const sliverPaddingBar = SliverPadding(padding: EdgeInsets.symmetric(vertical: 10));

BorderRadius categoryBorderRadius = BorderRadius.circular(40);
BorderRadius borderRadiusApp = BorderRadius.circular(20);
const Radius radiusApp = Radius.circular(15);

class InputStyle {
  static InputDecoration inputDecoration({
    String labelTextStr = '',
    String hintTextStr = '',
    Widget? suffixIcon,
    Widget? prefix,
  }) {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(10),
      labelText: labelTextStr,
      labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      hintText: hintTextStr,
      hintStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      suffixIcon: suffixIcon,
      prefix: prefix,
      prefixStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      // floatingLabelBehavior: FloatingLabelBehavior.always,
      alignLabelWithHint: true,
      // border: OutlineInputBorder(),
      // border: InputBorder.none,
    );
  }
}

Widget buttonCancelContext(BuildContext context) {
  return OutlinedButton(
    style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
    onPressed: () => Navigator.of(context).pop(),
    child: Text('Cancel'.i18n),
  );
}

Widget getLadingButton(BuildContext context) {
  return IconButton(
    icon: const Icon(Icons.menu),
    onPressed: () => Scaffold.of(context).openDrawer(),
  );
}

Widget getBackButton(BuildContext context) {
  return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop());
}
