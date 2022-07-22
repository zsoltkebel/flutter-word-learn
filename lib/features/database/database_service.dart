import 'package:cloud_firestore/cloud_firestore.dart';
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
}
