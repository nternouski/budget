// @dart=2.9

import 'package:flutter/material.dart';
import './widgets/bottom_navigation_bar_widget.dart';
import './common/color_constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: primary,
      ),
      home: BottomNavigationBarWidget(),
    );
  }
}
