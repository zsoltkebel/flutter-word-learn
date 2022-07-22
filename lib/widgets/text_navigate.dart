import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:word_learn/utils/constants.dart';

class TextNavigate extends StatelessWidget {
  final String? leadingText;
  final String actionText;
  final String? trailingText;
  final VoidCallback onTap;

  const TextNavigate({
    Key? key,
    required this.actionText,
    required this.onTap,
    this.leadingText,
    this.trailingText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(children: <TextSpan>[
          TextSpan(
              text: leadingText ?? '',
              style: const TextStyle(
                color: Constants.kDarkGreyColor,
              )),
          TextSpan(
              recognizer: TapGestureRecognizer()..onTap = onTap,
              text: actionText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Constants.kDarkBlueColor,
              )),
          TextSpan(
              text: trailingText ?? '',
              style: const TextStyle(
                color: Constants.kDarkGreyColor,
              )),
        ]));
  }
}
