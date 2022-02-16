import 'package:flutter/material.dart';
import 'package:word_learn/model/word.dart';

class DetailsPage extends StatelessWidget {
  final Word word;

  const DetailsPage(this.word, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(word.word),
              Text(word.translation),
            ],
          ),
        ),
      ),
    );
  }
}
