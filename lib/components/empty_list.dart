import 'package:flutter/material.dart';

class EmptyList extends StatelessWidget {
  final String urlImage;
  final String text;

  const EmptyList({Key? key, required this.urlImage, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Image.asset(urlImage, width: 270, height: 270),
          const SizedBox(height: 40),
          Text(text, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
