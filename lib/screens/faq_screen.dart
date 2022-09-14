import 'dart:developer';

import 'package:budget/common/styles.dart';
import 'package:flutter/material.dart';

class FAQ {
  String answer;
  String question;

  FAQ({required this.answer, required this.question});
}

List<FAQ> faqListData = [
  FAQ(
    question: 'How to create a transaction?',
    answer: 'First you need to create a wallet, the transaction belong to a wallet with a specific currency.',
  ),
];

class FAQScreen extends StatefulWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => FAQPageState();
}

class FAQPageState extends State<FAQScreen> {
  bool isExpand = false;
  int selected = -1;
  final TextEditingController search = TextEditingController(text: '');
  final List<FAQ> filtered = faqListData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: theme.textTheme.titleLarge,
        leading: getBackButton(context),
        title: const Text('FAQ'),
      ),
      body: Column(children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: search,
                textInputAction: TextInputAction.search,
                decoration: InputStyle.inputDecoration(labelTextStr: 'Search'),
                onFieldSubmitted: (input) {
                  filtered.clear();
                  filtered
                      .addAll(faqListData.where((faq) => faq.question.contains(input) || faq.answer.contains(input)));
                  setState(() {});
                },
              ),
            ),
            IconButton(
              onPressed: () {
                filtered.clear();
                filtered.addAll(
                    faqListData.where((faq) => faq.question.contains(search.text) || faq.answer.contains(search.text)));
                setState(() {});
              },
              icon: const Icon(Icons.search),
            )
          ],
        ),
        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 80),
                  child: Column(
                    children: List.generate(
                      filtered.length,
                      (index) => Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 3),
                        child: ExpansionTile(
                          key: Key(index.toString()),
                          initiallyExpanded: index == selected,
                          iconColor: theme.disabledColor,
                          title: Text(filtered[index].question, style: theme.textTheme.titleLarge),
                          onExpansionChanged: (newState) {
                            isExpand = newState;
                            setState(() => selected = newState ? index : -1 /* isExpand=newState; */);
                          },
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0, bottom: 10, left: 17, right: 17),
                              child: Row(children: [Expanded(child: Text(filtered[index].answer))]),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ]),
    );
  }
}
