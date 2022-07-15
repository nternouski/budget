import 'package:flutter/material.dart';
import '../common/color_constants.dart';
import '../json/daily_json.dart';

class CreatOrUpdateWalletScreen extends StatefulWidget {
  @override
  _CreatOrUpdateWalletScreenState createState() => _CreatOrUpdateWalletScreenState();
}

class _CreatOrUpdateWalletScreenState extends State<CreatOrUpdateWalletScreen> {
  final sizedBoxHeight = const SizedBox(height: 15);
  final smallSizedBoxHeight = const SizedBox(height: 10);

  _CreatOrUpdateWalletScreenState() {
    daily.sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: getBody(),
    );
  }

  Widget getBody() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [Text("asdasd")],
      ),
    );
  }
}
