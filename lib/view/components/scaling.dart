import 'package:flutter/material.dart';

class ScalingController {
  void Function({
    Duration duration,
    Curve curve,
    double scale,
    void Function()? onEnd,
  }) animateScale = (({
    Duration duration = const Duration(),
    Curve curve = Curves.linear,
    double scale = 1.0,
    void Function()? onEnd,
  }) {});

  void dispose() {
    animateScale = (({
      Duration duration = const Duration(),
      Curve curve = Curves.linear,
      double scale = 1.0,
      void Function()? onEnd,
    }) {});
  }
}

class Scaling extends StatefulWidget {
  final Widget child;
  final Function? onTap;
  final ScalingController? controller;

  const Scaling({
    Key? key,
    required this.child,
    required this.controller,
    this.onTap,
  }) : super(key: key);

  @override
  _ScalingState createState() => _ScalingState();
}

class _ScalingState extends State<Scaling> {
  Function()? onScaleEnd;
  double scale = 1.0;
  Curve scaleCurve = Curves.linear;
  Duration scaleDuration = const Duration(milliseconds: 70);

  @override
  void initState() {
    super.initState();

    widget.controller?.animateScale = _animateScale;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: scale,
      duration: scaleDuration,
      curve: scaleCurve,
      onEnd: onScaleEnd,
      child: widget.child,
    );
  }

  void _animateScale({
    Duration duration = const Duration(),
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
