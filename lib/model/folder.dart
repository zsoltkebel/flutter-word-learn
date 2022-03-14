import 'package:cloud_firestore/cloud_firestore.dart';

class Folder {
  final String? id;
  String name;
  bool reverse;
  String language1;
  String language2;
  CollectionReference? entries;

  Folder({
    this.id,
    required this.name,
    required this.language1,
    required this.language2,
    this.reverse = false,
    this.entries,
  });

  Folder.fromSnapshot(DocumentSnapshot doc)
      : id = doc.id,
        name = doc['name'],
        reverse = doc['reverse'],
        language1 = doc['lang-1'],
        language2 = doc['lang-2'],
        entries = doc.reference.collection('entries');
}
