import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:word_learn/model/word.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class FirebaseStorageHelper {
  static storageRefToRec(String fileName) {
    return 'recordings/$fileName';
  }

  static Future<void> _uploadFile(File? file, String path) async {
    print('file to upload: ${file}');
    if (file == null) return;
    try {
      await firebase_storage.FirebaseStorage.instance.ref(path).putFile(file);
    } on firebase_core.FirebaseException catch (e) {
      print(e);
      // e.g, e.code == 'canceled'
    }
  }

  static Future<void> _downloadFile({
    required File toFile,
    required String storageRef,
  }) async {
    try {
      await firebase_storage.FirebaseStorage.instance
          .ref(storageRef)
          .writeToFile(toFile);
    } on firebase_core.FirebaseException catch (e) {
      toFile.delete(); //TODO do i need this?
      // e.g, e.code == 'canceled'
    }
  }

  static Future<void> uploadRecording1({
    required Word word,
  }) {
    return _uploadFile(word.rec1, storageRefToRec(word.documentID! + '.m4a'));
  }

  static Future<void> downloadRecording1({
    required Word word,
    toCache = true,
  }) async {
    Directory appDir = await (toCache
        ? getTemporaryDirectory()
        : getApplicationDocumentsDirectory());
    word.rec1 = File('${appDir.path}/${word.storageRefToRec1}');

    return _downloadFile(toFile: word.rec1!, storageRef: word.storageRefToRec1!);
    // print(rec1!.path);
  }

  static Future<void> downloadRecording2({
    required Word word,
    toCache = true,
  }) async {
    Directory appDir = await (toCache
        ? getTemporaryDirectory()
        : getApplicationDocumentsDirectory());
    word.rec2 = File('${appDir.path}/${word.storageRefToRec2}');

    return _downloadFile(toFile: word.rec2!, storageRef: word.storageRefToRec2!);
    // print(rec1!.path);
  }
}
