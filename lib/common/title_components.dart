import 'package:flutter/material.dart';

import '../i18n/index.dart';

enum TitleAction { create, update }

class TitleOfComponent {
  final TitleAction action;
  final String label;

  const TitleOfComponent({required this.action, required this.label});

  bool createMode() {
    return action == TitleAction.create;
  }

  bool updateMode() {
    return action == TitleAction.update;
  }

  getTitle(ThemeData theme) {
    String actionLabel = action == TitleAction.update ? 'Save'.i18n : 'Add'.i18n;
    return Text('$actionLabel $label', style: theme.textTheme.titleLarge);
  }

  getButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(action == TitleAction.update ? Icons.save : Icons.add, color: Colors.white),
        const SizedBox(width: 5),
        Text(
          action == TitleAction.update ? 'Save'.i18n : 'Add'.i18n,
          style: const TextStyle(color: Colors.white),
        )
      ],
    );
  }
}
