import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:word_learn/model/custom_user_info.dart';

/// A simple list tile that display user name and icon in future.
/// Usually used in listviews.
class UserListTile extends StatefulWidget {
  final CustomUserInfo usr;
  final Widget? trailing;

  const UserListTile({
    Key? key,
    required this.usr,
    this.trailing,
  }) : super(key: key);

  @override
  State<UserListTile> createState() => _UserListTileState();
}

class _UserListTileState extends State<UserListTile> {

  @override
  Widget build(BuildContext context) {
    if (widget.usr.uid == FirebaseAuth.instance.currentUser?.uid) {
      return Container(); // Do not show current user among results
    }
    return ListTile(
      onTap: () {
        // setState(() {
        //   if (isSelected) {
        //     selected?.removeWhere((u) => u.uid == usr.uid);
        //   } else {
        //     selected?.add(usr);
        //   }
        // });
      },
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        child:
        Text(widget.usr.displayName?.substring(0, 1).toUpperCase() ?? ""),
      ),
      title: Text(widget.usr.displayName!),
      trailing: widget.trailing,
    );
  }
}