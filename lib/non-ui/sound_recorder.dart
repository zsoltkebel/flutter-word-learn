import 'dart:io';
import 'package:record/record.dart';

class SoundRecorder {
  static const defaultFileName = 'voice_recording.aac';

  final Record record;
  String? pathToSaveAudioFile;
  String? pathToRecording;

  SoundRecorder({
    this.pathToSaveAudioFile,
    this.pathToRecording,
  }) : record = Record();

  bool get hasRecording => pathToRecording != null;

  Future<bool> get isRecording => record.isRecording();

  Future<void>? start() {
    return record.start(path: pathToSaveAudioFile);
  }

  Future<String?> stop() async {
    if (await record.isRecording()) {
      pathToRecording = await record.stop();
      return pathToRecording; // return path to file
    } else {
      return Future.value(null);
    }
  }

  Future deleteRecording() async {
    if (pathToRecording != null) {
      File recordingFile = File(pathToRecording!.replaceFirst('file://', ''));
      await recordingFile.delete();
      pathToRecording = null;
    }
  }
}
