import 'package:budget/common/theme.dart';
import 'package:flutter/material.dart';

import '../i18n/index.dart';

BorderRadius borderRadiusApp = BorderRadius.circular(20);
const Radius radiusApp = Radius.circular(15);
const borderOutlet = BorderSide(width: 2, style: BorderStyle.solid);

Color getContrastOf(Color color) {
  return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}

OutlinedButton getButtonCancelContext(BuildContext context) {
  final color = Theme.of(context).colorScheme.error;
  return OutlinedButton(
    style: OutlinedButton.styleFrom(foregroundColor: color, side: borderOutlet.copyWith(color: color)),
    onPressed: () => Navigator.of(context).pop(),
    child: Text('Cancel'.i18n),
  );
}

IconButton getLadingButton(BuildContext context) {
  return IconButton(
    icon: const Icon(Icons.menu),
    onPressed: () => Scaffold.of(context).openDrawer(),
  );
}

IconButton getBackButton(BuildContext context) {
  return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop());
}

class ButtonThemeStyle {
  static ButtonStyle? getStyle(ThemeTypes type, BuildContext context) {
    Color? foregroundColor;
    Color? backgroundColor;
    if (type == ThemeTypes.primary) {
      foregroundColor = Theme.of(context).colorScheme.onPrimary;
      backgroundColor = Theme.of(context).colorScheme.primary;
    }
    if (type == ThemeTypes.accent) {
      foregroundColor = Theme.of(context).colorScheme.onSecondary;
      backgroundColor = Theme.of(context).colorScheme.secondary;
    }
    if (type == ThemeTypes.warn) {
      foregroundColor = Theme.of(context).colorScheme.onError;
      backgroundColor = Theme.of(context).colorScheme.error;
    }
    return ElevatedButton.styleFrom(foregroundColor: foregroundColor, backgroundColor: backgroundColor, elevation: 0.0);
  }
}

Widget getLoadingProgress({required BuildContext context, double size = 45}) {
  return SizedBox(
    width: size,
    height: size,
    child: CircularProgressIndicator(
      strokeWidth: 3,
      color: Theme.of(context).colorScheme.primary,
    ),
  );
}
