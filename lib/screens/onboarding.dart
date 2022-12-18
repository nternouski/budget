import 'package:budget/common/classes.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../common/error_handler.dart';
import '../components/select_currency.dart';
import '../model/currency.dart';
import '../server/user_service.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OnBoardingState();
}

UserService userService = UserService();

class _OnBoardingState extends State<OnBoarding> {
  bool isLastPage = false;
  Currency? defaultCurrency;
  final controller = PageController();
  final Duration durationAnimation = const Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return buildOnBoarding(context, theme);
  }

  buildOnBoarding(BuildContext context, ThemeData theme) {
    var pages = [
      BuildPage(
        urlImage: 'assets/images/bank-login.png',
        title: 'Welcome to Budget App',
        subtitle: 'Login with your user created with the button below or keep the steps to Sign Up.',
        children: [ElevatedButton(onPressed: () => userService.login(context), child: const Text('LOGIN'))],
      ),
      BuildPage(
        urlImage: 'assets/images/currencies.png',
        title: 'Select Default Currency',
        subtitle: 'Before start we need to know what will be the default currency, you can change later.',
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 35, right: 35),
            child: SelectCurrency(
              initialCurrencyId: defaultCurrency?.id ?? '',
              onSelect: (c) => setState(() => defaultCurrency = c),
            ),
          )
        ],
      ),
    ];
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(bottom: 80),
        child: PageView(
          controller: controller,
          onPageChanged: (index) => setState(() => isLastPage = index == pages.length - 1),
          children: pages,
        ),
      ),
      bottomSheet: Container(
        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                onPressed: () {
                  AboutDialogClass.show(context);
                },
                icon: const Icon(Icons.info),
                color: Colors.grey),
            Center(
              child: SmoothPageIndicator(
                controller: controller,
                count: pages.length,
                effect: WormEffect(
                  spacing: 20,
                  dotColor: theme.disabledColor,
                  activeDotColor: theme.colorScheme.primary,
                ),
                onDotClicked: (index) =>
                    controller.animateToPage(index, duration: durationAnimation, curve: Curves.ease),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (isLastPage) {
                  if (defaultCurrency == null) {
                    return HandlerError().setError('First yoy must set a default currency');
                  }
                  await userService.singUp(context, defaultCurrency!);
                } else {
                  controller.nextPage(duration: durationAnimation, curve: Curves.ease);
                }
              },
              child: Text(isLastPage ? 'SIGN UP' : '  NEXT  '),
            ),
          ],
        ),
      ),
    );
  }
}

class BuildPage extends StatelessWidget {
  final String urlImage;
  final String title;
  final String subtitle;
  final List<Widget> children;

  const BuildPage({
    required this.urlImage,
    required this.title,
    required this.subtitle,
    required this.children,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(urlImage, width: 270, height: 270),
        const SizedBox(height: 30),
        Text(title,
            textAlign: TextAlign.center, style: theme.textTheme.headline6?.copyWith(color: theme.colorScheme.primary)),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 17, height: 1.5),
          ),
        ),
        const SizedBox(height: 20),
        ...children
      ],
    );
  }
}
