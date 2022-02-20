import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:word_learn/model/word.dart';

class FirestoreManager {
  static CollectionReference words =
      FirebaseFirestore.instance.collection('words');

  static Future<void> updateWord(Word word) {
    return words
        .doc(word.documentID)
        .set(
          {
            'word': word.word,
            'translation': word.translation,
          },
          SetOptions(merge: true),
        )
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  static Future<DocumentSnapshot?> getWord(String? documentID) {
    if (documentID == null) {
      return Future.value(null);
    } else {
      return words.doc(documentID).get();
    }
  }
}
