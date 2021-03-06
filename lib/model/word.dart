import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class Word {
  final String? documentID;
  String word;
  String translation;
  String?
      storageRefToRec1; // full storage reference of the recording in firebase storage (not just name of file)
  String? storageRefToRec2;
  File? rec1; // local recording file
  File? rec2; // local recording file

  Word({
    required this.word,
    required this.translation,
    this.documentID,
    this.storageRefToRec1,
    this.storageRefToRec2,
    this.rec1,
    this.rec2,
  });

  Word.fromSnapshot(QueryDocumentSnapshot doc)
      : documentID = doc.id,
        word = doc['word'],
        translation = doc['translation'] {
    try {
      storageRefToRec1 = doc['r-w'];
    } on StateError catch (e) {
      // e.g, e.code == 'canceled'
    }
    try {
      storageRefToRec2 = doc['r-t'];
    } on StateError catch (e) {
      // e.g, e.code == 'canceled'
    }
  }

  void update(DocumentSnapshot doc) {
    word = doc['word'];
    translation = doc['translation'];
    try {
      storageRefToRec1 = doc['r-w'];
    } on StateError catch (e) {
      // e.g, e.code == 'canceled'
    }
    try {
      storageRefToRec2 = doc['r-t'];
    } on StateError catch (e) {
      // e.g, e.code == 'canceled'
    }
  }

  Word copyWith({required String id}) {
    return Word(
      word: word,
      translation: translation,
      documentID: id,
      storageRefToRec1: storageRefToRec1,
      storageRefToRec2: storageRefToRec2,
      rec1: rec1,
      rec2: rec2,
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'word': word,
      'translation': translation,
    };
    if (storageRefToRec1 != null) {
      map['r-w'] = storageRefToRec1!;
    }
    if (storageRefToRec2 != null) {
      map['r-t'] = storageRefToRec2!;
    }
    return map;
  }
}
