import 'package:cloud_firestore/cloud_firestore.dart';

class Word {
  String word;
  String translation;

  Word(this.word, this.translation);

  Word.fromSnapshot(QueryDocumentSnapshot doc)
      : word = doc['word'],
        translation = doc['translation'];
}
