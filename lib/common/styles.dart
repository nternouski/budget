import 'package:flutter/material.dart';
import '../common/color_constants.dart';

const titleStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: black);
const bodyTextStyle = TextStyle(fontSize: 17, color: black, fontWeight: FontWeight.w500);

const sliverPaddingBar = SliverPadding(padding: EdgeInsets.symmetric(vertical: 10));

class InputStyle {
  static InputDecoration inputDecoration({String labelTextStr = "", String hintTextStr = ""}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(10),
      labelText: labelTextStr,
      hintText: hintTextStr,
      labelStyle: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: black),
      hintStyle: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: grey),
      border: InputBorder.none,
    );
  }

  static TextStyle textStyle({String labelTextStr = "", String hintTextStr = ""}) {
    return const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: black);
  }
}
