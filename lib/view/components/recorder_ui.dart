import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:word_learn/non-ui/sound_player.dart';
import 'package:word_learn/non-ui/sound_recorder.dart';
import 'package:word_learn/view/components/bubble.dart';
import 'package:word_learn/view/components/progress_bar.dart';
import 'package:word_learn/view/components/scaling.dart';

const maxRecordDuration = Duration(seconds: 5);
const defaultFadeDuration = Duration(milliseconds: 400);

class RecorderUI extends StatefulWidget {
  final bool enabled;
  final Function? onRecordingStarted;
  final Function? onRecordingStopped;
  final Function? onPlayingStarted;
  final Function? onDiscardRecording;
  final Function(File?)? onRecordingFileChanged;
  final Duration duration;
  final String? pathToAudioFile;
  final TextEditingController? textEditingController;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;

  const RecorderUI({
    Key? key,
    this.pathToAudioFile,
    this.onRecordingStarted,
    this.onRecordingStopped,
    this.onPlayingStarted,
    this.onDiscardRecording,
    this.onRecordingFileChanged,
    this.duration = maxRecordDuration,
    this.enabled = true,
    this.textEditingController,
    this.onFieldSubmitted,
    this.textInputAction = TextInputAction.done,
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

  FocusNode textFieldFocusNode = FocusNode();

  Color? backgroundColor = Colors.white;
  Duration backgroundColorFadeDuration = const Duration(milliseconds: 400);
  Function()? onEnd;

  ScalingController scalingController = ScalingController();

  Duration? recordDuration;

  @override
  void initState() {
    super.initState();

    _timerController.addListener(
        () => setState(() {})); // update UI to display progress change

    _timerController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        if (await recorder.isRecording) {
          _stopRecording();
          _fadeOutPrimaryBackground();
        } else if (recorder.hasRecording) {
          _timerController.value = 0.0;
        }
      }
    });

    textFieldFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _timerController.dispose();
    scalingController.dispose();
    textFieldFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaling(
        controller: scalingController,
        child: Bubble(
          child: AnimatedContainer(
            onEnd: onEnd,
            duration: backgroundColorFadeDuration,
            color: backgroundColor,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                print('gesture detector tap');
                if (textFieldFocusNode.hasFocus && recorder.hasRecording) {
                  _playRecording();
                }
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ProgressBar(progress: _timerController.value),
                  ),
                  _buildInputLayer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLayer() => Row(
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
                  child: _buildInputContent(),
                ),
              ),
            ),
          ),
          _buildOptionButton(),
          // _buildOptionButtons(),
        ],
      );

  Widget _buildInputContent() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              height: textFieldFocusNode.hasFocus ? null : 0.0,
              width: double.infinity,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: textFieldFocusNode.hasFocus ? 1.0 : 0.0,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: recorder.hasRecording
                      ? Row(
                          children: [
                            Icon(
                              Icons.play_circle_fill,
                              size: 12.0,
                              color: Theme.of(context).textTheme.caption?.color,
                            ),
                            const SizedBox(
                              width: 4.0,
                            ),
                            Text(
                              'Tap to listen',
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ],
                        )
                      : Text(
                          'Hold microphone ro record',
                          style: Theme.of(context).textTheme.caption,
                        ),
                ),
              ),
            ),
          ),
        ],
      );

  Widget _buildTextField() => TextFormField(
        autofocus: true,
        controller: widget.textEditingController,
        focusNode: textFieldFocusNode,
        keyboardType: TextInputType.text,
        textInputAction: widget.textInputAction,
        style: Theme.of(context).textTheme.titleLarge,
        decoration: const InputDecoration(
          // labelText: 'Translation',
          border: InputBorder.none,
          hintText: 'Type here...',
        ),
        onFieldSubmitted: widget.onFieldSubmitted,
        onTap: () {
          if (textFieldFocusNode.hasFocus && recorder.hasRecording) {
            _playRecording();
          }
        },
      );

  Widget _buildOptionButton({bool enabled = true}) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: recorder.hasRecording
            ? GestureDetector(
                behavior: HitTestBehavior.translucent,
                // onTap: _discardRecording,
                onTap: _showDeleteRecordingActionSheet,
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Icon(
                    Icons.mic_off,
                    color: Colors.red,
                  ),
                ),
              )
            : GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (details) async =>
                    enabled ? _startRecording() : null,
                onTapCancel: () {
                  if (widget.enabled) {
                    // setState(() {
                    //   _scaleAnimationController.reverse();
                    //   _timerController.stop();
                    // });
                  }
                },
                onTapUp: (details) async => enabled
                    ? (await recorder.isRecording
                        ? _finishProgressAnimation()
                        : null)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Icon(
                    _timerController.isAnimating ? Icons.mic : Icons.mic_none,
                    color: enabled
                        ? (_timerController.isAnimating
                            ? Colors.red
                            : Colors.grey[1000])
                        : Colors.grey[300],
                  ),
                ),
              ),
      );

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

  void _animateContainerColor({
    Duration duration = defaultFadeDuration,
    Color? color = Colors.white,
    Function()? onEnd,
  }) {
    setState(() {
      backgroundColorFadeDuration = duration;
      backgroundColor = color;
      this.onEnd = onEnd;
    });
  }

  void _animateTap() {
    Duration duration = const Duration(milliseconds: 70);
    scalingController.animateScale(
      duration: duration,
      scale: 0.95,
      onEnd: () => scalingController.animateScale(duration: duration),
    );
  }

  void _fadeOutPrimaryBackground() {
    _animateContainerColor(
        duration: const Duration(microseconds: 1),
        // very slight delay for immediate color change
        color: Theme.of(context).primaryColor,
        onEnd: () {
          _timerController.value = 0.0;
          _animateContainerColor();
        });
  }

  void _startRecording() async {
    scalingController.animateScale(
      duration: const Duration(milliseconds: 400),
      scale: 1.05,
      curve: Curves.fastOutSlowIn,
    );
    _animateContainerColor(
      color: Colors.grey[300],
    );

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
    scalingController.animateScale(
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

  void _showDeleteRecordingActionSheet() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: const Text('Delete recording'),
            isDestructiveAction: true,
            onPressed: () {
              _discardRecording();
              Navigator.pop(context);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
