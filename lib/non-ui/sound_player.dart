import 'package:just_audio/just_audio.dart';

class SoundPlayer {
  final player = AudioPlayer();

  get isPlaying => player.playing;

  Future<Duration?> setFile({required String? pathToFile}) {
    if (pathToFile != null) {
      pathToFile = pathToFile.replaceFirst('file://', '');
      // print('path to recording file: $pathToFile');
      return player.setFilePath(pathToFile);
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
