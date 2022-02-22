import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';


class Word {
  final String? documentID;
  String word;
  String translation;
  String? storageRefToRec1; // full storage reference of the recording in firebase storage (not just name of file)
  String? storageRefToRec2;
  File? rec1; // local recording file
  File? rec2; // local recording file

  Word(
    this.word,
    this.translation, {
    this.storageRefToRec1,
    this.storageRefToRec2,
    this.rec1,
    this.rec2,
  }) : documentID = null;

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
