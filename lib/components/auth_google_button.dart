import 'package:budget/server/user_service.dart';
import 'package:flutter/material.dart';

class AuthButton extends StatefulWidget {
  final AuthOption option;
  final String text;
  final void Function() onPressed;
  const AuthButton({super.key, required this.option, required this.text, required this.onPressed});

  @override
  AuthButtonState createState() => AuthButtonState();
}

class AuthButtonState extends State<AuthButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: OutlinedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        onPressed: widget.onPressed,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 9, 0, 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.option == AuthOption.email) const Icon(Icons.email_rounded, color: Colors.black54, size: 30),
              if (widget.option == AuthOption.google)
                const Image(image: AssetImage('assets/images/google-logo.png'), height: 26),
              const SizedBox(width: 10),
              Text(
                widget.text,
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
