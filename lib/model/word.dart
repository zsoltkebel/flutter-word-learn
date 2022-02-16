import 'package:cloud_firestore/cloud_firestore.dart';

class Word {
  String documentID;
  String word;
  String translation;

  Word.fromSnapshot(QueryDocumentSnapshot doc)
      : documentID = doc.id,
        word = doc['word'],
        translation = doc['translation'];
}
