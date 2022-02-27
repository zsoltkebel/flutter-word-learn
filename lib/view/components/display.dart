import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:word_learn/non-ui/sound_player.dart';
import 'package:word_learn/view/components/bubble.dart';
import 'package:word_learn/view/components/info_section.dart';
import 'package:word_learn/view/components/progress_bar.dart';
import 'package:word_learn/view/components/scaling.dart';

class Display extends StatefulWidget {
  final String? text;
  final File? recording;
  final Function(String)? onTextChanged;
  final GlobalKey<FormState>? formKey;

  const Display({
    Key? key,
    this.text,
    this.recording,
    this.onTextChanged,
    this.formKey,
  }) : super(key: key);

  @override
  _DisplayState createState() => _DisplayState();
}

class _DisplayState extends State<Display> with TickerProviderStateMixin {
  final FocusNode textFieldFocusNode = FocusNode();

  final textController = TextEditingController();
  bool isLoading = false;
  bool isTextFieldEnabled = false;

  final ScalingController scalingController = ScalingController();

  final player = SoundPlayer();
  Duration? recordDuration;

  late final AnimationController _timerController =
      AnimationController(vsync: this, duration: recordDuration);

  @override
  void initState() {
    super.initState();
    _timerController.addListener(() => setState(() {}));

    _timerController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        _timerController.value = 0.0;
      }
    });
  }

  @override
  void didUpdateWidget(covariant Display oldWidget) {
    super.didUpdateWidget(oldWidget);

    updateFile();
  }

  @override
  void dispose() {
    scalingController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Scaling(
          controller: scalingController,
          child: GestureDetector(
            onTapDown: (details) => scalingController.animateScale(
              scale: 0.95,
              duration: const Duration(milliseconds: 200),
            ),
            onTapUp: (details) => scalingController.animateScale(
                duration: const Duration(milliseconds: 200)),
            onTap: () {
              playRecording();
            },
            child: Bubble(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ProgressBar(
                      progress: _timerController.value,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 18.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.text ?? '',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 200),
                                child: widget.recording != null
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.play_circle_fill,
                                              size: 12.0,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  ?.color,
                                            ),
                                            const SizedBox(
                                              width: 4.0,
                                            ),
                                            Text(
                                              'Tap to listen',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption,
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        // widget.recording != null
                        //     ? const Icon(Icons.volume_up)
                        //     : Container(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void playRecording() async {
    if (_timerController.duration != null) {
      await player.play();
      _timerController.forward(from: 0.0);
    }
  }

  void updateFile() async {
    if (widget.recording != null) {
      _timerController.duration =
          await player.setFile(path: widget.recording?.path);
    }
  }
}
