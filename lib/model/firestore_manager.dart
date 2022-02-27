import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:word_learn/model/firebase_storage_helper.dart';
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

  static Future deleteWord(Word word) {
    return words.doc(word.documentID).delete().then((value) {
      print("Word Deleted");
    }).catchError((error) => print("Failed to delete user: $error"));
  }

  static Future deleteWordFull(Word word) async {
    print('deleting word and recordings: ${word.documentID}');
    if (word.storageRefToRec1 != null) {
      await FirebaseStorageHelper.deleteFile(path: word.storageRefToRec1!);
    }
    if (word.storageRefToRec2 != null) {
      await FirebaseStorageHelper.deleteFile(path: word.storageRefToRec2!);
    }
    await deleteWord(word);
  }

  static Future<DocumentSnapshot?> getWord(String? documentID) {
    if (documentID == null) {
      return Future.value(null);
    } else {
      return words.doc(documentID).get();
    }
  }
}
