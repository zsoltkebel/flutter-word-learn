import 'package:flutter/material.dart';

const double iconSize = 14.0;

class InfoIcons extends StatelessWidget {
  final bool hasText;
  final bool hasRecording;

  const InfoIcons({
    Key? key,
    required this.hasText,
    required this.hasRecording,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            width: hasText ? iconSize : 0.0,
            duration: const Duration(milliseconds: 300),
            child: AnimatedScale(
              curve: Curves.bounceInOut,
              scale: hasText ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.title,
                size: iconSize,
                color: Theme.of(context)
                    .textTheme
                    .caption
                    ?.color
                    ?.withOpacity(0.3),
              ),
            ),
          ),
          const SizedBox(width: 2.0),
          AnimatedContainer(
            width: hasRecording ? iconSize : 0.0,
            duration: const Duration(milliseconds: 300),
            child: AnimatedScale(
              curve: Curves.bounceInOut,
              scale: hasRecording ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              child: Icon(
                Icons.mic,
                size: iconSize,
                color: Theme.of(context)
                    .textTheme
                    .caption
                    ?.color
                    ?.withOpacity(0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
