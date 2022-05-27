import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserInfoModel {
  final String uid;
  final String? displayName;
  final String? photoURL;
  final List<String?> friendUIDs;

  UserInfoModel.fromSnapshot(DocumentSnapshot doc)
      : uid = doc.id,
        displayName = doc['display-name'],
        photoURL = doc['photo-url'],
        friendUIDs = List.from(doc['friend-uid-array']);

  UserInfoModel.fromUser(User user)
      : uid = user.uid,
        displayName = user.displayName,
        photoURL = user.photoURL,
        friendUIDs = [];

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'display-name': displayName,
      'photo-url': photoURL,
      'friend-uid-array': friendUIDs,
    };
  }
}
