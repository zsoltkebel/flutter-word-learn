import 'package:just_audio/just_audio.dart';

class SoundPlayer {
  final player = AudioPlayer();

  get isPlaying => player.playing;

  Future setURL(String url) {
    return player.setUrl(url);
  }

  Future<Duration?> setFile({required String? path}) {
    if (path != null) {
      path = path.replaceFirst('file://', '');
      // print('path to recording file: $pathToFile');
      return player.setFilePath(path);
    } else {
      throw Exception('No audio file specified');
    }
  }

  Future play() async {
    player.seek(const Duration());
    player.play();
  }

  Future pause() async {
    await player.pause();
  }

  Future resume() async {
    await player.play();
  }

  Future stop() async {
    await player.stop();
  }
}
