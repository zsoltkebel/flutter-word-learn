import 'package:cloud_firestore/cloud_firestore.dart';

/// Translation Collection
class TransCollection {
  final String? id;
  String name;
  String owner; // uid of owner
  String ownerName;
  List<String> reverseFor;
  List<String> visibleFor;
  String language1;
  String language2;
  CollectionReference? entries;
  Map<String, dynamic> members;

  get shared =>
      members.keys.length > 0; //TODO more elaborate check with owner id ...

  TransCollection({
    this.id,
    required this.name,
    required this.language1,
    required this.language2,
    this.owner = '',
    this.ownerName = '',
    this.members = const {},
    this.reverseFor = const [],
    this.visibleFor = const [],
    this.entries,
  });

  TransCollection.fromDocumentSnapshot(DocumentSnapshot doc)
      : id = doc.id,
        name = doc['name'],
        reverseFor = List.from(doc['reverse-for']),
        visibleFor = List.from(doc['can-view']),
        language1 = doc['lang-1'],
        language2 = doc['lang-2'],
        entries = doc.reference.collection('entries'),
        owner = doc['owner-id'],
        ownerName = doc['owner-name'],
        members = Map<String, dynamic>.from(doc['members']);
}
