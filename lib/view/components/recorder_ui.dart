import 'package:flutter/material.dart';
import 'package:word_learn/non-ui/sound_player.dart';
import 'package:word_learn/non-ui/sound_recorder.dart';

class RecorderUI extends StatefulWidget {
  final Widget? child;
  final bool enabled;
  final Function? onRecordingStarted;
  final Function? onRecordingStopped;
  final Function? onPlayingStarted;
  final Function? onDiscardRecording;
  final Duration duration;
  final String? pathToAudioFile;

  const RecorderUI({
    Key? key,
    this.pathToAudioFile,
    this.onRecordingStarted,
    this.onRecordingStopped,
    this.onPlayingStarted,
    this.onDiscardRecording,
    this.duration = const Duration(seconds: 5),
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

  final tween = Tween<double>(begin: 1.0, end: 1.2);
  late final AnimationController _scaleAnimationController =
      AnimationController(
    duration: const Duration(milliseconds: 400),
    reverseDuration: const Duration(milliseconds: 800),
    vsync: this,
  );

  // for tapDown
  late final Animation<double> _animation = CurvedAnimation(
    parent: _scaleAnimationController,
    curve: Curves.fastOutSlowIn,
    reverseCurve: Curves.elasticIn,
  );
  late final Animation<double> _scale =
      Tween<double>(begin: 1.0, end: 1.05).animate(_animation);
  late final AnimationController _timerController =
      AnimationController(vsync: this, duration: widget.duration);

  // for tap action
  late final AnimationController _tapAnimationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 70));
  late final Animation<double> _tapAnimation = CurvedAnimation(
    parent: _tapAnimationController,
    curve: Curves.linear,
    // reverseCurve: Curves.elasticOut,
  );
  late final Animation<double> _tapScaleAnimation =
      Tween<double>(begin: 1.0, end: 0.95).animate(_tapAnimation);

  late Animation<double> _currentScaleAnimation = _scale;

  Color? backgroundColor = Colors.white;
  Duration dur = Duration(milliseconds: 400);

  final Stopwatch stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();

    _timerController.addListener(() {
      setState(() {});
    });
    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        print('animation done time\'s up');
        setState(() {
          dur = Duration(milliseconds: 0);
          backgroundColor = Theme.of(context).primaryColor;
          Future.delayed(const Duration(milliseconds: 10), () {
            setState(() {
              dur = Duration(milliseconds: 200);
              backgroundColor = Colors.white;
            });
          });
          _timerController.value = 0.0;
        });
      }
    });
    _animation.addListener(() {
      setState(() {});
    });

    // For sound recording and playback
    recorder.init();
    player.init();
  }

  @override
  void dispose() {
    _timerController.dispose();
    _tapAnimationController.dispose();
    _scaleAnimationController.dispose();
    // For sound recording and playback
    recorder.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // backgroundColor = _timerController.isAnimating ? Colors.grey[300] : Colors.white;
    return Center(
      child: ScaleTransition(
        scale: _currentScaleAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: AnimatedContainer(
            duration: dur,
            color: backgroundColor,
            child: Stack(
              children: [
                Positioned.fill(
                  child: _buildProgressBar(progress: _timerController.value),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: AnimatedOpacity(
                            opacity: _timerController.isAnimating ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: widget.child ?? Container(),
                          ),
                        ),
                      ),
                      Row(
                        children: _buildOptionButtons(),
                      ),
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

  List<Widget> _buildOptionButtons() {
    List<Widget> optionButtons = [];
    if (recorder.hasRecording) {
      optionButtons.addAll([
        GestureDetector(
          onTap: _playRecording,
          child: const Icon(Icons.play_arrow),
        ),
        const SizedBox(
          width: 25.0,
        ),
        GestureDetector(
          onTap: _discardRecording,
          child: const Icon(Icons.mic_off),
        ),
      ]);
    } else {
      optionButtons.add(_buildRecordButton(enabled: widget.enabled));
    }

    return optionButtons;
  }

  Widget _buildRecordButton({bool enabled = true}) {
    final iconColor = enabled
        ? (_timerController.isAnimating ? Colors.red : Colors.grey[1000])
        : Colors.grey[300];
    return GestureDetector(
      onTapDown: (details) => enabled ? _startRecording() : null,
      onTapCancel: () {
        if (widget.enabled) {
          setState(() {
            _scaleAnimationController.reverse();
            _timerController.stop();
          });
        }
      },
      onTapUp: (details) => enabled ? _stopRecording() : null,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Icon(
          _timerController.isAnimating ? Icons.mic : Icons.mic_none,
          color: iconColor,
        ),
      ),
    );
  }

  void _startRecording() {

    setState(() {
      _timerController.duration =
          const Duration(seconds: 5); // max recording length
      _scaleAnimationController.forward();
      _timerController.forward();
      backgroundColor = Colors.grey[300];
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      // slight delay for starting to talk later than actual tap
      stopwatch.start();
      recorder.start();
      widget.onRecordingStarted?.call();
    });
  }

  void _stopRecording() {
    stopwatch.stop();
    recorder.stop();
    widget.onRecordingStopped?.call();
    setState(() {
      _scaleAnimationController.reverse();

      // quickly jump to end with animation
      _timerController.stop();
      _timerController.duration = const Duration(milliseconds: 150);
      _timerController.forward();
    });
  }

  void _playRecording() async {
    player.play(pathToAudioFile: widget.pathToAudioFile);
    widget.onPlayingStarted?.call();
    if (recorder.hasRecording) {
      _timerController.duration = stopwatch.elapsed;
      _timerController.forward(from: 0.0);
    }
  }

  void _discardRecording() {
    stopwatch.reset();
    recorder.deleteRecording();

    widget.onDiscardRecording?.call();
    setState(() {
      Animation<double> previousAnimation = _currentScaleAnimation;
      _currentScaleAnimation = _tapScaleAnimation;
      _tapAnimationController.forward().then((value) => _tapAnimationController
          .reverse()
          .then((value) => _currentScaleAnimation)
          .then((value) => _currentScaleAnimation = previousAnimation));

      _timerController.value = 0.0;
      _timerController.duration = const Duration(seconds: 5);
    });
  }
}
