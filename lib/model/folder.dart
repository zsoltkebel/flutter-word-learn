import 'package:cloud_firestore/cloud_firestore.dart';

class Folder {
  final String? documentID;
  String name;
  bool reverse;

  Folder({
    this.documentID,
    required this.name,
    this.reverse = false,
  });

  Folder.fromSnapshot(DocumentSnapshot doc)
      : documentID = doc.id,
        name = doc['name'],
        reverse = doc['reverse'];
}
