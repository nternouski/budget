import 'package:flutter/material.dart';

class IconCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  late final double size;

  IconCircle({required this.icon, required this.color, double? size, Key? key}) : super(key: key) {
    this.size = size ?? 39;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: color.withOpacity(0.17)),
      height: size,
      width: size,
      child: Icon(icon, color: color, size: size / 1.7),
    );
  }
}
