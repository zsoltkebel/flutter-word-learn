import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:word_learn/model/custom_user_info.dart';
import 'package:word_learn/widgets/friend_tile.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('friend-uid-array', arrayContains: uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return const CircularProgressIndicator.adaptive();
            }
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    final friend =
                    CustomUserInfo.fromSnapshot(snapshot.data!.docs[index]);

                    return FriendTile(friend: friend);
                  }),
            );
          }),
    );
  }
}
