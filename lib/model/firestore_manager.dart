import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:word_learn/model/word.dart';

class FirestoreManager {
  static CollectionReference words =
      FirebaseFirestore.instance.collection('words');

  static Future<void> updateWord(Word word) {
    return words
        .doc(word.documentID)
        .set(
          word.toJson(),
          SetOptions(merge: true),
        )
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  static Future<void> uploadFile(File? file, String path) async {
    print('file to upload: ${file}');
    if (file == null) return;
    try {
      await FirebaseStorage.instance.ref(path).putFile(file);
    } on FirebaseException catch (e) {
      print(e);
      // e.g, e.code == 'canceled'
    }
  }

  static Future deleteFile(String path) {
    return FirebaseStorage.instance.ref(path).delete();
  }

  static Future deleteWord(Word word) {
    return words.doc(word.documentID).delete().then((value) {
      print("Word Deleted");
    }).catchError((error) => print("Failed to delete user: $error"));
  }

  static deleteWordFull(Word word) {
    print('deleting word and recordings');
    if (word.storageRefToRec1 != null) {
      deleteFile(word.storageRefToRec1!);
    }
    if (word.storageRefToRec2 != null) {
      deleteFile(word.storageRefToRec2!);
    }
    deleteWord(word);
  }

  static Future<DocumentSnapshot?> getWord(String? documentID) {
    if (documentID == null) {
      return Future.value(null);
    } else {
      return words.doc(documentID).get();
    }
  }
}
