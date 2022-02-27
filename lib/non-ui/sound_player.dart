import 'package:just_audio/just_audio.dart';

class SoundPlayer {
  final player = AudioPlayer();

  get isPlaying => player.playing;

  Future setURL(String url) {
    return player.setUrl(url);
  }

  Future<Duration?> setFile({required String? path}) {
    // if (path != null) {
    //
    //   // print('path to recording file: $pathToFile');
    //   return player.setFilePath(path);
    // } else {
    //   throw Exception('No audio file specified');
    // }
    try {
      path = path!.replaceFirst('file://', '');
      return player.setFilePath(path);
    } on PlayerException catch (e) {
      // iOS/macOS: maps to NSError.code
      // Android: maps to ExoPlayerException.type
      // Web: maps to MediaError.code
      // Linux/Windows: maps to PlayerErrorCode.index
      print("Error code: ${e.code}");
      // iOS/macOS: maps to NSError.localizedDescription
      // Android: maps to ExoPlaybackException.getMessage()
      // Web/Linux: a generic message
      // Windows: MediaPlayerError.message
      print("Error message: ${e.message}");
    } on PlayerInterruptedException catch (e) {
      // This call was interrupted since another audio source was loaded or the
      // player was stopped or disposed before this audio source could complete
      // loading.
      print("Connection aborted: ${e.message}");
    } catch (e) {
      // Fallback for all errors
      print(e);
    }
    return Future.value(null);
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
