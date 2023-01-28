import 'package:flutter/material.dart';

import '../i18n/index.dart';
import '../common/styles.dart';

class FAQ {
  String answer;
  String question;

  FAQ({required this.answer, required this.question});
}

class FAQScreen extends StatefulWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => FAQPageState();
}

class FAQPageState extends State<FAQScreen> {
  bool isExpand = false;
  int selected = -1;
  final TextEditingController search = TextEditingController(text: '');

  static List<FAQ> faqListData = [
    FAQ(
      question: 'How to create a transaction?'.i18n,
      answer: 'First you need to create a wallet, the transaction belong to a wallet with a specific currency.'.i18n,
    ),
    FAQ(
      question: 'How can I remove the Ads?'.i18n,
      answer:
          'We use Ads to pay server expenses in the app, but if you insist on hiding ads, you can contact me by email and I will do something about it.'
              .i18n,
    ),
    FAQ(
      question: 'Do you notice some wrong in the wallet?'.i18n,
      answer: 'There are admin features, just let me know and I will enable those functions in your account.'.i18n,
    ),
    FAQ(
      question: 'My currency rate it is wrong?'.i18n,
      answer:
          'You can change the rate manually, go to Settings > Scroll down to \'Currency Rates\' > Click on the rate and will apear the form.'
              .i18n,
    ),
    FAQ(
      question: 'What it is Wise Sync?'.i18n,
      answer: 'The feature is to update wise movement, but it\'s in alpha and not works properly.'.i18n,
    ),
    FAQ(
      question: 'How can I contact with the developer?'.i18n,
      answer: 'You can send email to nahuelternouski@gmail.com.'.i18n,
    ),
  ];

  final List<FAQ> filtered = List.from(faqListData);

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

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
            const SizedBox(width: 15),
            Expanded(
              child: TextFormField(
                controller: search,
                decoration: InputStyle.inputDecoration(labelTextStr: 'Search'.i18n),
                onFieldSubmitted: (input) {
                  filtered.clear();
                  setState(() => filtered.addAll(getMatchSearch(search.text)));
                },
              ),
            ),
            IconButton(
              onPressed: () {
                filtered.clear();
                setState(() => filtered.addAll(getMatchSearch(search.text)));
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Column(
                    children: List.generate(filtered.length, (index) => getCardFaq(theme, index)),
                  ),
                ),
              )
            ],
          ),
        )
      ]),
    );
  }

  getCardFaq(ThemeData theme, int index) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 5),
      child: ExpansionTile(
        key: Key(index.toString()),
        initiallyExpanded: index == selected,
        iconColor: theme.disabledColor,
        title: Text(filtered[index].question, style: theme.textTheme.titleMedium),
        onExpansionChanged: (newState) {
          isExpand = newState;
          setState(() => selected = newState ? index : -1 /* isExpand=newState; */);
        },
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 17),
            child: Row(children: [Expanded(child: Text(filtered[index].answer))]),
          )
        ],
      ),
    );
  }

  List<FAQ> getMatchSearch(String text) {
    String search = text.toLowerCase().trim();
    searchFn(faq) => faq.question.toLowerCase().contains(search) || faq.answer.toLowerCase().contains(search);
    return List.from(faqListData.where(searchFn));
  }
}
