import 'package:flutter/material.dart';
import 'package:word_learn/view/components/info_icons.dart';

class InfoSection extends StatelessWidget {
  final String caption;
  final bool hasText;
  final bool hasRecording;

  const InfoSection({
    Key? key,
    required this.caption,
    required this.hasText,
    required this.hasRecording,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 20.0,
      ),
      child: Row(
        children: [
          Text(
            caption.toUpperCase(),
            style: Theme.of(context).textTheme.caption,
          ),
          Spacer(),
          InfoIcons(
            hasText: hasText,
            hasRecording: hasRecording,
          )
        ],
      ),
    );
  }
}
