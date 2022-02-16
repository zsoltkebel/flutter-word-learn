import 'package:flutter/cupertino.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:word_learn/sound_recorder.dart';

class SoundPlayer {

  FlutterSoundPlayer? audioPlayer;

  get isPlaying => audioPlayer!.isPlaying && !audioPlayer!.isPaused;

  Future init() async {
    audioPlayer = FlutterSoundPlayer();

    await audioPlayer!.openAudioSession();
    // audioPlayer!.onProgress!.listen((event) {
    //   Duration maxDuration = event.duration;
    //   Duration position = event.position;
    //
    //   print(position.inMilliseconds);
    //
    // });
  }

  void dispose() {
    audioPlayer!.closeAudioSession();
    audioPlayer = null;
  }

  Future play({whenFinished = VoidCallback}) async {
    audioPlayer!.setSubscriptionDuration(const Duration(milliseconds: 10));
    await audioPlayer!.startPlayer(fromURI: pathToSaveAudio, whenFinished: whenFinished);
  }

  Future pause() async {
    await audioPlayer!.pausePlayer();
  }

  Future resume() async {
    await audioPlayer!.resumePlayer();
  }

  Future stop() async {
    await audioPlayer!.stopPlayer();
  }

  Future togglePlaying({whenFinished = VoidCallback}) async {
    if (audioPlayer!.isPlaying) {
      await pause();
    } else if (audioPlayer!.isStopped) {
      await play(whenFinished: whenFinished);
    } else if (audioPlayer!.isPaused) {
      await resume();
    }
  }
}