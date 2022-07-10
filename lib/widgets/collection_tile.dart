import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:word_learn/model/folder.dart';

import 'package:word_learn/view/components/bubble.dart';
import 'package:word_learn/view/components/clickable.dart';
import 'package:word_learn/screens/collection.dart';

class CollectionTile extends StatelessWidget {
  final Folder folder;

  const CollectionTile({Key? key, required this.folder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Clickable(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CollectionPage(
                  folder: folder,
                ),
          ),
        );
      },
      child: Bubble(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    folder.name,
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleLarge,
                  ),
                ),
                folder.owner != FirebaseAuth.instance.currentUser?.uid
                    ? Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    '${folder.ownerName}\'s',
                    style: Theme
                        .of(context)
                        .textTheme
                        .caption,
                  ),
                )
                    : Container(),
              ],
            ),
            const SizedBox(height: 5.0),
            Text(
              "${folder.language1} - ${folder.language2}",
              style: Theme
                  .of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: const Color(0xFF101334)),
            ),
            folder.shared
                ? Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                folder.members.values.take(2).join(', '),
                style: Theme
                    .of(context)
                    .textTheme
                    .caption,
              ),
            )
                : Container(),
          ],
        ),
      ),
    );
  }
}
