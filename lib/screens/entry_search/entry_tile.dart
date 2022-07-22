import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:word_learn/model/trans_collection.dart';
import 'package:word_learn/model/trans_entry.dart';
import 'package:word_learn/view/components/info_icons.dart';
import 'package:word_learn/view/details_page.dart';

class EntryTile extends StatelessWidget {
  final TrEntry entry;
  final TransCollection collection;

  const EntryTile({
    Key? key,
    required this.entry,
    required this.collection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final swap = collection.reverseFor.contains(uid);
    var infoIcons = [
      InfoIcons(
        hasText: entry.text1.isNotEmpty,
        hasRecording: entry.storageRef1 != null,
      ),
      const SizedBox(
        height: 4.0,
      ),
      InfoIcons(
        hasText: entry.text2.isNotEmpty,
        hasRecording: entry.storageRef2 != null,
      ),
    ];
    if (swap) {
      infoIcons = infoIcons.reversed.toList();
    }
    return ListTile(
      title: Text(swap ? entry.text2 : entry.text1),
      subtitle: Text(swap ? entry.text1 : entry.text2),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        children: infoIcons,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DetailsPage(
                    entry,
                    folder: collection,
                  )),
        );
      },
    );
  }
}
