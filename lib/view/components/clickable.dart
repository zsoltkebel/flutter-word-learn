import 'package:flutter/material.dart';

class Clickable extends StatefulWidget {
  final Widget? child;
  final void Function()? onTap;

  const Clickable({
    Key? key,
    this.child,
    this.onTap,
  }) : super(key: key);

  @override
  _ClickableState createState() => _ClickableState();
}

class _ClickableState extends State<Clickable> {
  double scale = 1.0;
  Duration scaleDuration = const Duration(milliseconds: 200);
  Curve scaleCurve = Curves.linear;
  Function()? onScaleEnd;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: scale,
      duration: scaleDuration,
      curve: scaleCurve,
      onEnd: onScaleEnd,
      child: GestureDetector(
        onTapDown: (details) => _animateScale(scale: 0.9),
        onTapUp: (details) => _animateScale(),
        onTapCancel: () => _animateScale(),
        onTap: widget.onTap,
        child: widget.child,
      ),
    );
  }

  void _animateScale({
    Duration duration = const Duration(milliseconds: 100),
    Curve curve = Curves.linear,
    double scale = 1.0,
    Function()? onEnd,
  }) {
    setState(() {
      scaleDuration = duration;
      scaleCurve = curve;
      this.scale = scale;
      onScaleEnd = onEnd;
    });
  }
}
