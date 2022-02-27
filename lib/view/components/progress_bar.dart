import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress;

  const ProgressBar({Key? key, this.progress = 0.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Row(
        children: [
          Container(
            width: constraints.maxWidth * progress,
            color: Theme.of(context).primaryColor,
          ),
        ],
      );
    });
  }
}
