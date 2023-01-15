import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/classes.dart';
import '../common/styles.dart';
import '../common/error_handler.dart';
import '../components/select_currency.dart';
import '../model/user.dart';
import '../model/currency.dart';
import '../server/user_service.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OnBoardingState();
}

final UserService userService = UserService();

class _OnBoardingState extends State<OnBoarding> {
  bool isLastPage = false;
  Currency? defaultCurrency;
  AuthOption authOption = AuthOption.google;
  String email = '';
  String password = '';
  bool _passwordVisible = true;
  bool _disclosureAcceptedSignUp = false;

  final controller = PageController();
  final Duration durationAnimation = const Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return buildOnBoarding(context, theme);
  }

  buildOnBoarding(BuildContext context, ThemeData theme) {
    var pages = [
      ListView(children: [
        BuildPage(
          urlImage: 'assets/images/bank-login.png',
          title: 'Welcome to Budget App',
          subtitle: 'Login with your user created with the button below or keep the steps to Sign Up.',
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 35, right: 35),
              child: Column(children: [
                InputDecorator(
                  decoration: const InputDecoration(labelText: 'Choice One Option'),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<AuthOption>(
                      isDense: true,
                      value: authOption,
                      onChanged: (AuthOption? option) => option != null ? setState(() => authOption = option) : null,
                      items: AuthOption.values
                          .map((c) => DropdownMenuItem(value: c, child: Text('  ${c.toShortString()}')))
                          .toList(),
                    ),
                  ),
                ),
                if (authOption == AuthOption.email)
                  Column(children: [
                    TextFormField(
                      initialValue: email,
                      keyboardType: TextInputType.emailAddress,
                      autovalidateMode: AutovalidateMode.always,
                      decoration: InputStyle.inputDecoration(labelTextStr: 'Email', hintTextStr: 'email@email.com'),
                      validator: (String? value) => value != null && value.isValidEmail() ? null : 'Email is Required.',
                      onChanged: (String value) => email = value,
                    ),
                    TextFormField(
                      initialValue: password,
                      autovalidateMode: AutovalidateMode.always,
                      validator: (String? value) =>
                          value != null && value.isValidPassword() ? null : 'Password min 6 characters.',
                      onChanged: (String value) => password = value,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        suffixIcon: IconButton(
                          icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                          onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                        ),
                      ),
                    ),
                  ]),
                const SizedBox(height: 15),
                ElevatedButton(
                    onPressed: () {
                      if (authOption == AuthOption.email && (!email.isValidEmail() || !password.isValidPassword())) {
                        return HandlerError().setError('First you must set a email and password');
                      }
                      userService.login(context, authOption, email, password);
                    },
                    child: const Text('LOGIN'))
              ]),
            )
          ],
        ),
      ]),
      ListView(
        children: [
          BuildPage(
            urlImage: 'assets/images/currencies.png',
            title: 'Select Default Currency',
            subtitle: 'Before start we need to know what will be the default currency, you can change later.',
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 35, right: 35),
                child: Column(children: [
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'Choice One Option'),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<AuthOption>(
                        isDense: true,
                        value: authOption,
                        onChanged: (AuthOption? option) => option != null ? setState(() => authOption = option) : null,
                        items: AuthOption.values
                            .map((c) => DropdownMenuItem(value: c, child: Text('  ${c.toShortString()}')))
                            .toList(),
                      ),
                    ),
                  ),
                  if (authOption == AuthOption.email)
                    Column(children: [
                      TextFormField(
                        initialValue: email,
                        keyboardType: TextInputType.emailAddress,
                        autovalidateMode: AutovalidateMode.always,
                        decoration: InputStyle.inputDecoration(labelTextStr: 'Email', hintTextStr: 'email@email.com'),
                        validator: (String? value) =>
                            value != null && value.isValidEmail() ? null : 'Email is Required.',
                        onChanged: (String value) => email = value,
                      ),
                      TextFormField(
                        initialValue: password,
                        autovalidateMode: AutovalidateMode.always,
                        validator: (String? value) =>
                            value != null && value.isValidPassword() ? null : 'Password min 6 characters.',
                        onChanged: (String value) => password = value,
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          suffixIcon: IconButton(
                            icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                            onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                          ),
                        ),
                      ),
                    ]),
                  SelectCurrency(
                    initialCurrencyId: defaultCurrency?.id ?? '',
                    onSelect: (c) => setState(() => defaultCurrency = c),
                  ),
                  const SizedBox(height: 15),
                  CheckboxListTile(
                    title: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: 'By continuing, I agree to ', style: TextStyle(color: theme.hintColor)),
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: TextStyle(color: theme.colorScheme.primary, decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                try {
                                  launchUrl(Uri.https('nternouski.web.app', '/apps/budget/terms'),
                                      mode: LaunchMode.inAppWebView);
                                } catch (e) {
                                  debugPrint(e.toString());
                                }
                              },
                          ),
                          TextSpan(text: ' and ', style: TextStyle(color: theme.hintColor)),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(color: theme.colorScheme.primary, decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                try {
                                  launchUrl(Uri.https('nternouski.web.app', '/apps/budget/privacy-policy'),
                                      mode: LaunchMode.inAppWebView);
                                } catch (e) {
                                  debugPrint(e.toString());
                                }
                              },
                          ),
                          TextSpan(
                              text:
                                  ' and allow to verify credentials. Also, the app not request permission only if you check the biometric auth you can use for login and the app is not a AccessibilityTool.',
                              style: TextStyle(color: theme.hintColor)),
                        ],
                      ),
                    ),
                    value: _disclosureAcceptedSignUp,
                    onChanged: (newValue) {
                      setState(() => _disclosureAcceptedSignUp = newValue ?? false);
                    },
                    controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
                  ),
                ]),
              )
            ],
          ),
        ],
      )
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
              onPressed: () => AboutDialogClass.show(context),
              icon: const Icon(Icons.info),
              color: Colors.grey,
            ),
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
                    return HandlerError().setError('First you must set a default currency');
                  }
                  if (authOption == AuthOption.email && (!email.isValidEmail() || !password.isValidPassword())) {
                    return HandlerError().setError('First you must set a email and password');
                  }
                  if (!_disclosureAcceptedSignUp) {
                    return HandlerError().setError('You must accept the terms and conditions.');
                  }
                  await userService.singUp(context, authOption, email, password, defaultCurrency!);
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
        const SizedBox(height: 30),
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
