import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? uid;
  final String? email;
  final String? displayName;
  bool? isVerified;
  String? password;

  UserModel(
      {this.uid, this.email, this.password, this.displayName, this.isVerified});

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'display-name': displayName,
    };
  }

  UserModel.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : uid = doc.id,
        email = doc.data()!['email'],
        displayName = doc.data()!['display-name'];

  UserModel copyWith({
    bool? isVerified,
    String? uid,
    String? email,
    String? password,
    String? displayName,
  }) {
    return UserModel(
        uid: uid ?? this.uid,
        email: email ?? this.email,
        password: password ?? this.password,
        displayName: displayName ?? this.displayName,
        isVerified: isVerified ?? this.isVerified
    );
  }
}
