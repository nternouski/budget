import 'package:flutter/material.dart';

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
    return Container(
      decoration: BoxDecoration(
        border: withBorder ? Border.all(color: color, width: 1.5) : null,
        borderRadius: BorderRadius.circular(30),
        color: color.withOpacity(0.17),
      ),
      height: size,
      width: size,
      child: Icon(icon, color: color, size: size / 1.8),
    );
  }
}
