import 'package:budget/common/styles.dart';
import 'package:flutter/material.dart';

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
          border: Border.all(width: 2, color: show ? borderColor ?? Theme.of(context).hintColor : Colors.transparent),
          color: color,
          borderRadius: oval ? borderRadiusApp : BorderRadius.circular(14),
        ),
        child: finalChild,
      ),
    );
  }
}
