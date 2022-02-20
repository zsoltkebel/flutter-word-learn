import 'package:flutter/cupertino.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:word_learn/non-ui/sound_recorder.dart';

class SoundPlayer {
  final FlutterSoundPlayer player;

  SoundPlayer() : player = FlutterSoundPlayer();

  get isPlaying => player.isPlaying && !player.isPaused;

  Future init() async {
    await player.openPlayer();
    // audioPlayer!.onProgress!.listen((event) {
    //   Duration maxDuration = event.duration;
    //   Duration position = event.position;
    //
    //   print(position.inMilliseconds);
    //
    // });
  }

  void dispose() {
    player.closePlayer();
  }

  Future play({
    String? pathToAudioFile = SoundRecorder.defaultPathToAudioFile,
    Function()? whenFinished,
  }) async {
    await player.startPlayer(
        fromURI: pathToAudioFile, whenFinished: whenFinished);
  }

  Future pause() async {
    await player.pausePlayer();
  }

  Future resume() async {
    await player.resumePlayer();
  }

  Future stop() async {
    await player.stopPlayer();
  }

  Future togglePlaying({whenFinished = VoidCallback}) async {
    if (player.isPlaying) {
      await pause();
    } else if (player.isStopped) {
      await play(whenFinished: whenFinished);
    } else if (player.isPaused) {
      await resume();
    }
  }

  Future getDuration() async {
    return (await player.getProgress())['duration'];
  }
}
