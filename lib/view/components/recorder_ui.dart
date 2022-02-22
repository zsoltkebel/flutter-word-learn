import 'dart:io';

import 'package:flutter/material.dart';
import 'package:word_learn/non-ui/sound_player.dart';
import 'package:word_learn/non-ui/sound_recorder.dart';

const maxRecordDuration = Duration(seconds: 5);

class RecorderUI extends StatefulWidget {
  final Widget? child;
  final bool enabled;
  final Function? onRecordingStarted;
  final Function? onRecordingStopped;
  final Function? onPlayingStarted;
  final Function? onDiscardRecording;
  final Function(File?)? onRecordingFileChanged;
  final Duration duration;
  final String? pathToAudioFile;

  const RecorderUI({
    Key? key,
    this.pathToAudioFile,
    this.onRecordingStarted,
    this.onRecordingStopped,
    this.onPlayingStarted,
    this.onDiscardRecording,
    this.onRecordingFileChanged,
    this.duration = maxRecordDuration,
    this.child,
    this.enabled = true,
  }) : super(key: key);

  @override
  _RecorderUIState createState() => _RecorderUIState();
}

class _RecorderUIState extends State<RecorderUI> with TickerProviderStateMixin {
  // For recording and playback
  late final recorder =
      SoundRecorder(pathToSaveAudioFile: widget.pathToAudioFile);
  final player = SoundPlayer();

  /// Animation controller for progress bar animation
  late final AnimationController _timerController =
      AnimationController(vsync: this, duration: widget.duration);

  Color? backgroundColor = Colors.white;
  Duration backgroundColorFadeDuration = const Duration(milliseconds: 400);

  /// values for animated scaling below
  Function()? onScaleEnd;
  double scale = 1.0;
  Curve scaleCurve = Curves.linear;
  Duration scaleDuration = const Duration(milliseconds: 70);

  Duration? recordDuration;

  @override
  void initState() {
    super.initState();

    _timerController.addListener(() {
      // update UI to display progress change
      setState(() {});
    });

    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _stopRecording();
        _fadeOutPrimaryBackground();
      }
    });
  }

  @override
  void dispose() {
    _timerController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedScale(
        scale: scale,
        duration: scaleDuration,
        curve: scaleCurve,
        onEnd: onScaleEnd,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: AnimatedContainer(
            duration: backgroundColorFadeDuration,
            color: backgroundColor,
            child: Stack(
              children: [
                Positioned.fill(
                  child: _buildProgressBar(progress: _timerController.value),
                ),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 10.0,
                          ),
                          child: Center(
                            child: AnimatedOpacity(
                              opacity: _timerController.isAnimating ? 0.0 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: widget.child ?? Container(),
                            ),
                          ),
                        ),
                      ),
                      _buildOptionButtons(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar({double progress = 0.0}) =>
      LayoutBuilder(builder: (context, constraints) {
        return Row(
          children: [
            Container(
              width: constraints.maxWidth * progress,
              color: Theme.of(context).primaryColor,
            ),
          ],
        );
      });

  Widget _buildOptionButtons() => recorder.hasRecording
      ? Row(children: [
          // const VerticalDivider(
          //   indent: 10.0,
          //   endIndent: 10.0,
          //   width: 2.0,
          //   thickness: 0.0,
          // ),
          GestureDetector(
            onTap: _playRecording,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Icon(
                Icons.play_arrow,
                color: Theme.of(context).textTheme.caption?.color,
              ),
            ),
          ),
          Opacity(
            opacity: _timerController.isAnimating ? 0.0 : 1.0,
            child: const VerticalDivider(
              indent: 10.0,
              endIndent: 10.0,
              width: 2.0,
              thickness: 0.0,
            ),
          ),
          GestureDetector(
            onTap: _discardRecording,
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: Icon(
                Icons.mic_off,
                color: Colors.red,
              ),
            ),
          ),
        ])
      : _buildRecordButton(enabled: widget.enabled);

  Widget _buildRecordButton({bool enabled = true}) {
    final iconColor = enabled
        ? (_timerController.isAnimating ? Colors.red : Colors.grey[1000])
        : Colors.grey[300];
    return GestureDetector(
      onTapDown: (details) async => enabled ? _startRecording() : null,
      onTapCancel: () {
        if (widget.enabled) {
          // setState(() {
          //   _scaleAnimationController.reverse();
          //   _timerController.stop();
          // });
        }
      },
      onTapUp: (details) async => enabled
          ? (await recorder.isRecording ? _finishProgressAnimation() : null)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Icon(
          _timerController.isAnimating ? Icons.mic : Icons.mic_none,
          color: iconColor,
        ),
      ),
    );
  }

  /// Animates progress indicator background to 1.0 position quickly
  void _finishProgressAnimation() {
    // quickly jump to end with animation
    _timerController.stop();
    _timerController.duration = const Duration(milliseconds: 150);
    _timerController.forward();
  }

  /// Animates the progress indicator from 0.0 to 1.0 under maxDuration
  void _startProgressAnimation() {
    _timerController.duration = maxRecordDuration; // max recording length
    _timerController.forward();
  }

  void _scale({
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

  void _animateTap() {
    Duration duration = const Duration(milliseconds: 70);
    _scale(
      duration: duration,
      scale: 0.95,
      onEnd: () => _scale(duration: duration),
    );
  }

  void _fadeOutPrimaryBackground() {
    setState(() {
      // for immediate color change
      backgroundColorFadeDuration = const Duration();
      backgroundColor = Theme.of(context).primaryColor;
      // part below needs some delay for previous part to take effect
      Future.delayed(const Duration(microseconds: 1), () {
        setState(() {
          backgroundColorFadeDuration = const Duration(milliseconds: 400);
          backgroundColor = Colors.white;
        });
      });
      _timerController.value = 0.0;
    });
  }

  void _startRecording() async {
    // scale bigger slowly
    _scale(
      duration: const Duration(milliseconds: 400),
      scale: 1.05,
      curve: Curves.fastOutSlowIn,
    );
    setState(() {
      backgroundColor = Colors.grey[300];
    });

    await recorder.start();
    widget.onRecordingStarted?.call();
    _startProgressAnimation();
  }

  void _stopRecording() async {
    String? pathToRecording = await recorder.stop();
    recordDuration = await player.setFile(path: pathToRecording);
    print('path to recording: $pathToRecording');

    widget.onRecordingFileChanged?.call(pathToRecording == null
        ? null
        : File(pathToRecording.replaceFirst('file://', '')));

    widget.onRecordingStopped?.call();

    // scale bounce back to original
    _scale(
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
    );
  }

  void _playRecording() async {
    player.play();
    widget.onPlayingStarted?.call();
    if (recorder.hasRecording) {
      _timerController.duration = recordDuration;
      _timerController.forward(from: 0.0);
    }
  }

  void _discardRecording() {
    recorder.deleteRecording();
    widget.onDiscardRecording?.call();

    widget.onRecordingFileChanged?.call(null);

    _animateTap();
  }
}
