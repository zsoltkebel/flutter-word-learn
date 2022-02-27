import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class FirebaseStorageHelper {
  static storageRefToRec(String fileName) {
    return 'recordings/$fileName';
  }

  static Future<String?> _uploadFile(File file, String path) async {
    print('file to upload: ${file}');
    try {
      final task = await firebase_storage.FirebaseStorage.instance
          .ref(path)
          .putFile(file);
      return Future.value(task.ref.fullPath);
    } on firebase_core.FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print(e);
      return Future.value(null);
    }
  }

  static Future<void> _downloadFile({
    required File toFile,
    required String storageRef,
  }) async {
    print('trying to download: $storageRef');
    try {
      await firebase_storage.FirebaseStorage.instance
          .ref(storageRef)
          .writeToFile(toFile);
    } on firebase_core.FirebaseException catch (e) {
      toFile.delete(); //TODO do i need this?
      // e.g, e.code == 'canceled'
    }
  }

  static Future deleteFile({required String path}) async {
    try {
      await firebase_storage.FirebaseStorage.instance.ref(path).delete();
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
  }

  static Future<List<String?>> uploadFiles({
    required Map<File?, String?> fileRefMap,
  }) async {
    List<String?> storageRefs = [];
    for (final entry in fileRefMap.entries) {
      File? file = entry.key;
      String? ref = entry.value;
      if (file == null || ref == null) {
        storageRefs.add(null);
      } else {
        storageRefs.add(await _uploadFile(file, ref));
      }
    }
    return Future.value(storageRefs);
  }

  /// Downloads recordings at provided storage references.
  /// If reference is null, the corresponding File in the
  /// return list is also going to be null.
  static Future<List<File?>> downloadFiles({
    required List<String?> storageRefs,
    toCache = true,
  }) async {
    Directory appDir = await (toCache
        ? getTemporaryDirectory()
        : getApplicationDocumentsDirectory());

    List<File?> files = [];
    for (String? storageRef in storageRefs) {
      if (storageRef == null) {
        files.add(null);
      } else {
        File file = File('${appDir.path}/$storageRef');
        await _downloadFile(toFile: file, storageRef: storageRef);
        files.add(file);
      }
    }

    return Future.value(files);
  }
}
