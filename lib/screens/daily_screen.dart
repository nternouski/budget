import 'package:flutter/material.dart';
import '../common/styles.dart';
import '../components/daily_item.dart';
import '../components/spend_graphic.dart';
import '../common/color_constants.dart';
import '../json/daily_json.dart';

class DailyScreen extends StatefulWidget {
  @override
  _DailyScreenState createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  _DailyScreenState() {
    daily.sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: getBody(),
      ),
    );
  }

  List<Widget> getBody() {
    var size = MediaQuery.of(context).size;
    return [
      SliverAppBar(
        pinned: true,
        backgroundColor: white,
        leading: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: IconButton(icon: const Icon(Icons.menu, color: black), onPressed: () => Scaffold.of(context).openDrawer()),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Daily Transaction", style: titleStyle),
            Icon(Icons.search, color: black),
          ],
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.all(0),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            SpendGraphic(daily),
          ]),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(childCount: daily.length, (context, index) => DailyItem(daily[index])),
      ),
    ];
  }
}
