import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:word_learn/model/trans_collection.dart';
import 'package:word_learn/model/trans_entry.dart';
import 'package:word_learn/model/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  addUserData(UserModel userData) async {
    await _db.collection('users').doc(userData.uid).set(userData.toMap());
  }

  Future<List<UserModel>> retrieveUserData() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _db.collection('users').get();
    return snapshot.docs.map(UserModel.fromDocumentSnapshot).toList();
  }

  Future<String> retrieveUserName(UserModel user) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _db.collection("users").doc(user.uid).get();
    return snapshot.data()!["displayName"];
  }

  /// Fetch list of collections for a specific user
  Future<List<TransCollection>> retrieveCollectionsFor(UserModel user) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _db
        .collection('folders')
        .where('can-view', arrayContains: user.uid)
        .get();
    return snapshot.docs.map(TransCollection.fromDocumentSnapshot).toList();
  }

  /// Fetch list of entries of a specific collection
  Future<List<TrEntry>> retrieveEntriesOf(TransCollection collection) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _db
        .collection('folders')
        .doc(collection.id)
        .collection('entries')
        .get();
    return snapshot.docs.map(TrEntry.fromDocumentSnapshot).toList();
  }
}
