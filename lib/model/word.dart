import 'package:cloud_firestore/cloud_firestore.dart';

class Word {
  final String? documentID;
  String word;
  String translation;

  Word(this.word, this.translation) : documentID = null;

  Word.fromSnapshot(QueryDocumentSnapshot doc)
      : documentID = doc.id,
        word = doc['word'],
        translation = doc['translation'];

  void update(DocumentSnapshot doc) {
    word = doc['word'];
    translation = doc['translation'];
  }

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'translation': translation,
    };
  }
}
