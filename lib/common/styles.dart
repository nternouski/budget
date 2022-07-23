import 'package:flutter/material.dart';
import '../common/color_constants.dart';

class TextColor {
  static Color getContrastOf(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}

const titleStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: black);
const bodyTextStyle = TextStyle(fontSize: 17, color: black, fontWeight: FontWeight.w500);

const sliverPaddingBar = SliverPadding(padding: EdgeInsets.symmetric(vertical: 10));

BorderRadius borderRadiusApp = BorderRadius.circular(40);
const Radius radiusApp = Radius.circular(15);

class InputStyle {
  static InputDecoration inputDecoration({
    String labelTextStr = "",
    String hintTextStr = "",
    Icon? suffixIcon,
    Widget? prefix,
  }) {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(10),
      labelText: labelTextStr,
      labelStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: black.withOpacity(0.5)),
      hintText: hintTextStr,
      hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: grey.withOpacity(0.5)),
      suffixIcon: suffixIcon,
      prefix: prefix,
      prefixStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: black.withOpacity(0.5)),
      // floatingLabelBehavior: FloatingLabelBehavior.always,
      alignLabelWithHint: true,
      // border: OutlineInputBorder(),
      // border: InputBorder.none,
    );
  }
}

TextButton buttonCancelContext(BuildContext context) {
  return TextButton(
    style: TextButton.styleFrom(primary: Colors.red),
    onPressed: () => Navigator.of(context).pop(),
    child: const Text("Cancel"),
  );
}

Padding getLadingButton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 2),
    child: IconButton(icon: const Icon(Icons.menu, color: black), onPressed: () => Scaffold.of(context).openDrawer()),
  );
}

void displayError(BuildContext context, String test) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: red,
      content: Text(test),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
