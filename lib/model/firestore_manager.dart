import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:word_learn/model/firebase_storage_helper.dart';
import 'package:word_learn/model/folder.dart';
import 'package:word_learn/model/translation_entry.dart';

class FirestoreManager {
  static CollectionReference words =
      FirebaseFirestore.instance.collection('words');

  /// Can be used to add and update entry
  static Future<void> setEntry({Folder? folder, TranslationEntry? entry}) async {

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

  static Future? deleteEntry(Folder folder, TranslationEntry word) {
    return folder.entries?.doc(word.id).delete().then((value) {
      print("Word Deleted");
    }).catchError((error) => print("Failed to delete user: $error"));
  }

  static Future deleteEntryAndFiles(Folder folder, TranslationEntry entry) async {
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
}
