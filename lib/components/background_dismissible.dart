import 'package:flutter/material.dart';

import '../i18n/index.dart';

const double opacitySlide = 0.25;
const paddingSlide = SizedBox(width: 10);

class BackgroundEditDismissible extends StatelessWidget {
  final IconData? actionIcon;
  final String? action;
  const BackgroundEditDismissible({this.actionIcon, this.action, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.primary.withOpacity(opacitySlide),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            paddingSlide,
            Icon(actionIcon ?? Icons.edit, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Text(
              action ?? ' ${'Edit'.i18n}',
              style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w700),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}

class BackgroundDeleteDismissible extends StatelessWidget {
  final EdgeInsets padding;
  const BackgroundDeleteDismissible({this.padding = const EdgeInsets.all(0), super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.error.withOpacity(opacitySlide),
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                ' ${'Delete'.i18n}',
                style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w700),
                textAlign: TextAlign.right,
              ),
              const SizedBox(width: 10),
              Icon(Icons.delete, color: theme.colorScheme.error),
              paddingSlide,
            ],
          ),
        ),
      ),
    );
  }
}
