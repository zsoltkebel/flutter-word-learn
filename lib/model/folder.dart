import 'package:cloud_firestore/cloud_firestore.dart';

class Folder {
  final String? id;
  String name;
  String owner; // uid of owner
  String ownerName;
  bool reverse;
  List<String> reverseFor;
  String language1;
  String language2;
  CollectionReference? entries;
  Map<String, dynamic> members;

  get shared =>
      members.keys.length > 0; //TODO more elaborate check with owner id ...

  Folder({
    this.id,
    required this.name,
    required this.language1,
    required this.language2,
    this.owner = '',
    this.ownerName = '',
    this.members = const {},
    this.reverse = false,
    this.reverseFor = const [],
    this.entries,
  });

  Folder.fromSnapshot(DocumentSnapshot doc)
      : id = doc.id,
        name = doc['name'],
        reverse = doc['reverse'],
        reverseFor = List.from(doc['reverse-for']),
        language1 = doc['lang-1'],
        language2 = doc['lang-2'],
        entries = doc.reference.collection('entries'),
        owner = doc['owner-id'],
        ownerName = doc['owner-name'],
        members = Map<String, dynamic>.from(doc['members']);
}
