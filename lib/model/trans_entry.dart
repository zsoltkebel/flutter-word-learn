import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

const text1Key = 'text-1';
const text2Key = 'text-2';
const storageRef1Key = 'storage-ref-1';
const storageRef2Key = 'storage-ref-2';

/// Translation Entry
class TrEntry extends Equatable {
  final String? id;
  String text1;
  String text2;
  String?
      storageRef1; // full storage reference of the recording in firebase storage (not just name of file)
  String? storageRef2;
  File? recording1; // local recording file
  File? recording2; // local recording file

  TrEntry({
    required this.text1,
    required this.text2,
    this.id,
    this.storageRef1,
    this.storageRef2,
    this.recording1,
    this.recording2,
  });

  @override
  List<Object?> get props => [id, text1, text2];

  TrEntry.fromDocumentSnapshot(DocumentSnapshot doc)
      : id = doc.id,
        text1 = doc[text1Key],
        text2 = doc[text2Key] {
    try {
      storageRef1 = doc[storageRef1Key];
    } on StateError catch (e) {
      // e.g, e.code == 'canceled'
    }
    try {
      storageRef2 = doc[storageRef2Key];
    } on StateError catch (e) {
      // e.g, e.code == 'canceled'
    }
  }

  void update(DocumentSnapshot doc) {
    text1 = doc[text1Key];
    text2 = doc[text2Key];
    try {
      storageRef1 = doc[storageRef1Key];
    } on StateError catch (e) {
      // e.g, e.code == 'canceled'
    }
    try {
      storageRef2 = doc[storageRef2Key];
    } on StateError catch (e) {
      // e.g, e.code == 'canceled'
    }
  }

  TrEntry copyWith({required String id}) {
    return TrEntry(
      text1: text1,
      text2: text2,
      id: id,
      storageRef1: storageRef1,
      storageRef2: storageRef2,
      recording1: recording1,
      recording2: recording2,
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      text1Key: text1,
      text2Key: text2,
    };
    if (storageRef1 != null) {
      map[storageRef1Key] = storageRef1!;
    }
    if (storageRef2 != null) {
      map[storageRef2Key] = storageRef2!;
    }
    return map;
  }
}
