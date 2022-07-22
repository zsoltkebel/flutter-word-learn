import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:word_learn/model/firebase_storage_helper.dart';
import 'package:word_learn/model/trans_collection.dart';
import 'package:word_learn/model/trans_entry.dart';

class FirestoreManager {
  static CollectionReference words =
      FirebaseFirestore.instance.collection('words');

  /// Can be used to add and update entry
  static Future<void> setEntry(
      {TransCollection? folder, TransEntry? entry}) async {
    if (entry?.id == null) {
      entry =
          entry?.copyWith(id: (await folder?.entries?.add(entry.toJson()))!.id);
    }
    print('uploaded: ${entry?.id}');
    await FirebaseStorageHelper.uploadFiles(
      fileRefMap: {
        'recordings/${entry?.id!}-1.m4a': entry?.recording1,
        'recordings/${entry?.id!}-2.m4a': entry?.recording2,
      },
    ).then((storageRefs) {
      entry?.storageRef1 = storageRefs[0];
      entry?.storageRef2 = storageRefs[1];
    });

    return folder?.entries?.doc(entry?.id).set(entry?.toJson());
  }

  static Future? deleteEntry(TransCollection folder, TransEntry word) {
    return folder.entries?.doc(word.id).delete().then((value) {
      print("Word Deleted");
    }).catchError((error) => print("Failed to delete user: $error"));
  }

  static Future deleteEntryAndFiles(
      TransCollection folder, TransEntry entry) async {
    print('deleting entry and recordings: ${entry.id}');
    if (entry.storageRef1 != null) {
      await FirebaseStorageHelper.deleteFile(path: entry.storageRef1!);
    }
    if (entry.storageRef2 != null) {
      await FirebaseStorageHelper.deleteFile(path: entry.storageRef2!);
    }
    await deleteEntry(folder, entry);
  }

  static Future<DocumentSnapshot?> getWord(String? documentID) {
    if (documentID == null) {
      return Future.value(null);
    } else {
      return words.doc(documentID).get();
    }
  }

  static Future updateUserInfo({
    required String uid,
    required String? displayName,
    required String? photoURL,
  }) async {
    // final snapshot = await FirebaseFirestore.instance
    //     .collectionGroup('friends')
    //     .where('uid', isEqualTo: uid)
    //     .get();
    print('update info ${FieldPath.documentId}');

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('friends')
        .get();
    final values = {
      'display-name': displayName,
      'photo-url': photoURL,
    };

    final batch = FirebaseFirestore.instance.batch();

    batch.update(
        FirebaseFirestore.instance.collection('users').doc(uid), values);

    for (var doc in snapshot.docs) {
      final ref = FirebaseFirestore.instance
          .collection('users')
          .doc(doc.id)
          .collection('friends')
          .doc(uid);
      print('updating user info at: ${ref.path}');
      batch.update(ref, values);
    }

    return batch.commit();
  }

  static void addFriend({
    required DocumentReference person1,
    required DocumentReference person2,
  }) {
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot p1 = await transaction.get(person1);
      DocumentSnapshot p2 = await transaction.get(person2);

      // person2 -> friends -> person1
      transaction.update(person2, {
        'friend-uid-array': FieldValue.arrayUnion([p1.id])
      });
      // person1 -> friends -> person2
      transaction.update(person1, {
        'friend-uid-array': FieldValue.arrayUnion([p2.id])
      });
    }).catchError((e) => print(e));
  }

  static void removeFriend({
    required DocumentReference person1,
    required DocumentReference person2,
  }) {
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot p1 = await transaction.get(person1);
      DocumentSnapshot p2 = await transaction.get(person2);

      // person2 -> friends -> person1
      transaction.update(person2, {
        'friend-uid-array': FieldValue.arrayRemove([p1.id])
      });
      // person1 -> friends -> person2
      transaction.update(person1, {
        'friend-uid-array': FieldValue.arrayRemove([p2.id])
      });
    }).catchError((e) => print(e));
  }
}
