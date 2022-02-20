import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class SoundRecorder {
  static const defaultPathToAudioFile = 'voice_recording.aac';

  final FlutterSoundRecorder _recorder;
  final String? pathToSaveAudioFile;

  bool hasRecording = false;

  SoundRecorder({this.pathToSaveAudioFile = defaultPathToAudioFile})
      : _recorder = FlutterSoundRecorder();

  bool get isRecording => _recorder.isRecording;

  Future init() async {
    if (await Permission.microphone.request().isDenied) {
      throw RecordingPermissionException('Microphone permission denied');
    } else if (await Permission.microphone.isPermanentlyDenied) {
      openAppSettings();
    }

    await _recorder.openRecorder();
  }

  void dispose() {
    _recorder.closeRecorder();
  }

  Future start() async {
    if (_recorder.isStopped) {
      await _recorder.startRecorder(toFile: pathToSaveAudioFile);
      print('recorder started');
    } else {
      print('recorder is not stopped');
    }
  }

  Future stop() async {
    if (_recorder.isRecording) {
      await _recorder.stopRecorder();
      hasRecording = true;
      print('here');
    } else {
      print('Tried to stop recording when it has not been started yet');
    }
  }

  Future deleteRecording() async {
    if (_recorder.isStopped) {
      hasRecording = false;

      await _recorder.closeRecorder();
      await _recorder.openRecorder();
    }
  }
}
