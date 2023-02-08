import 'package:flutter/material.dart';

import '../i18n/index.dart';

class TextColor {
  static Color getContrastOf(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}

const sliverPaddingBar = SliverPadding(padding: EdgeInsets.symmetric(vertical: 10));

BorderRadius borderRadiusApp = BorderRadius.circular(20);
const Radius radiusApp = Radius.circular(15);
const borderOutlet = BorderSide(width: 2, style: BorderStyle.solid);

class AppInteractionBorder extends StatelessWidget {
  final Color? borderColor;
  final Color? color;
  final bool oval;
  final Widget child;
  final bool show;
  final EdgeInsetsGeometry? margin;
  final void Function()? onLongPress;
  final void Function()? onTap;

  const AppInteractionBorder({
    super.key,
    this.borderColor,
    this.color,
    required this.child,
    this.show = true,
    this.oval = false,
    this.margin,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final Widget finalChild;
    if (margin != null) {
      finalChild = Padding(padding: margin!, child: child);
    } else {
      finalChild = child;
    }

    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: show ? Border.all(width: 2, color: borderColor ?? Theme.of(context).hintColor) : null,
          color: color,
          borderRadius: oval ? borderRadiusApp : BorderRadius.circular(14),
        ),
        child: finalChild,
      ),
    );
  }
}

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
  final color = Theme.of(context).colorScheme.error;
  return OutlinedButton(
    style: OutlinedButton.styleFrom(foregroundColor: color, side: borderOutlet.copyWith(color: color)),
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
