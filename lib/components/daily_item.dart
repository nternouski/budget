import 'package:flutter/material.dart';
import '../screens/create_or_update_transaction_screen.dart';
import '../common/styles.dart';
import '../common/color_constants.dart';
import '../model/transaction.dart';
import '../json/categories_json.dart';

class DailyItem extends StatefulWidget {
  Transaction transaction;

  DailyItem(this.transaction, {Key? key}) : super(key: key);

  @override
  _DailyItemState createState() => _DailyItemState(transaction);
}

class _DailyItemState extends State<DailyItem> {
  Transaction transaction;

  final double opacitySlide = 0.1;
  final paddingSlide = const SizedBox(width: 20);

  _DailyItemState(this.transaction);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(transaction.id),
      background: slideRightBackground(),
      secondaryBackground: slideLeftBackground(),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          final bool res = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(transaction.name, style: titleStyle),
                  content: const Text("Are you sure you want to delete ?"),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("Cancel", style: TextStyle(color: Colors.black)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: const Text("Delete", style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        setState(() {
                          // TODO: Delete the item from DB etc..
                          // itemsList.removeAt(index);
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });
          return res;
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => CreateOrUpdateTransaction(transaction: transaction),
            ),
          );
        }
        return null;
      },
      child: InkWell(
        onTap: () {
          print("${transaction.name} clicked");
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: getItem(transaction),
        ),
      ),
    );
  }

  Widget slideRightBackground() {
    return Container(
      color: green.withOpacity(opacitySlide),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            paddingSlide,
            const Icon(Icons.edit, color: green),
            const Text(" Edit", style: TextStyle(color: green, fontWeight: FontWeight.w700), textAlign: TextAlign.left),
          ],
        ),
      ),
    );
  }

  Widget slideLeftBackground() {
    return Container(
      color: Colors.red.withOpacity(opacitySlide),
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(" Delete",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700), textAlign: TextAlign.right),
            const Icon(Icons.delete, color: Colors.red),
            paddingSlide,
          ],
        ),
      ),
    );
  }

  Widget getItem(Transaction transaction) {
    var size = MediaQuery.of(context).size;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: (size.width - 40) * 0.7,
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: grey.withOpacity(0.1)),
                    child: Center(
                      child: Image.asset(
                        categories
                            .firstWhere((book) => book.id == transaction.categoryId, orElse: () => categories[0])
                            .icon,
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                  paddingSlide,
                  Container(
                    width: (size.width - 90) * 0.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.name,
                          style: bodyTextStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          transaction.getDateFormat(),
                          style: TextStyle(fontSize: 12, color: black.withOpacity(0.5), fontWeight: FontWeight.w400),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: (size.width - 40) * 0.3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '\$ ${transaction.amount}',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15, color: colorsTypeTransaction[transaction.type]),
                  ),
                ],
              ),
            )
          ],
        ),
        const Padding(padding: EdgeInsets.only(left: 65, top: 10))
      ],
    );
  }
}
