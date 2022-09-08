import 'package:budget/common/theme.dart';
import 'package:flutter/material.dart';

abstract class ModelCommonInterface {
  late String id;

  ModelCommonInterface.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}

class ScreenInit {
  static Widget getScreenInit(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Inicializando..', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
          const SizedBox(height: 30),
          Progress.getLoadingProgress(context: context)
        ],
      ),
    ));
  }
}
