import 'package:flutter/material.dart';

class Bubble extends StatelessWidget {
  final Widget? child;
  final EdgeInsets? padding;
  final Color? color;
  final BoxBorder? border;

  const Bubble({
    Key? key,
    this.child,
    this.padding,
    this.color = Colors.white,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: color,
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10.0,
            // spreadRadius: 5.0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(padding: padding, child: child),
      ),
    );
  }
}
