import 'package:flutter/material.dart';

import '../common/styles.dart';

class IconCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final bool withBorder;

  const IconCircle({
    required this.icon,
    required this.color,
    this.size = 36,
    this.withBorder = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppInteractionBorder(
      borderColor: withBorder ? color : Colors.transparent,
      color: color.withOpacity(0.2),
      child: SizedBox(
        height: size,
        width: size,
        child: Icon(icon, color: color, size: size / 1.8),
      ),
    );
  }
}
