import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:word_learn/model/trans_collection.dart';

typedef SharingChangeCallback = void Function(bool shared);

/// Action button located at the trailing of a user list tile.
/// Can be toggled to add/remove user to/from the list of collaborators
/// of a collection.
class ShareToggleButton extends StatefulWidget {
  final String uid;
  final TransCollection collection;
  final bool isCollaborator; // for initial value
  final SharingChangeCallback? onSharingChanged;

  const ShareToggleButton({
    Key? key,
    required this.uid,
    required this.isCollaborator,
    required this.collection,
    this.onSharingChanged,
  }) : super(key: key);

  @override
  State<ShareToggleButton> createState() => _ShareToggleButtonState();
}

class _ShareToggleButtonState extends State<ShareToggleButton> {
  late bool isCollaborator = widget.isCollaborator;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        if (isCollaborator) {
          // remove
          FirebaseFirestore.instance
              .collection('folders')
              .doc(widget.collection.id)
              .update({
            'can-view': FieldValue.arrayRemove([widget.uid])
          });
          widget.collection.visibleFor.remove(widget.uid);
        } else {
          // add
          FirebaseFirestore.instance
              .collection('folders')
              .doc(widget.collection.id)
              .update({
            'can-view': FieldValue.arrayUnion([widget.uid])
          });
          widget.collection.visibleFor.add(widget.uid);
        }
        setState(() {
          isCollaborator = !isCollaborator;
        });
        widget.onSharingChanged?.call(isCollaborator);
      },
      style: isCollaborator
          ? ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.red),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0))),
            )
          : ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0))),
            ),
      child: Text(isCollaborator ? 'Remove' : 'Add'),
    );
  }
}
