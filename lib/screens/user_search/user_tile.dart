import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:word_learn/model/custom_user_info.dart';

/// A simple list tile that display user name and icon in future.
/// Usually used in listviews.
class UserTile extends StatelessWidget {
  final CustomUserInfo usr;
  final Widget? trailing;
  final ValueSetter<CustomUserInfo>? onTap;

  const UserTile({
    Key? key,
    required this.usr,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (usr.uid == FirebaseAuth.instance.currentUser?.uid) {
      return Container(); // Do not show current user among results
    }
    return ListTile(
      onTap: () => onTap?.call(usr),
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        child:
        Text(usr.displayName?.substring(0, 1).toUpperCase() ?? ""),
      ),
      title: Text(usr.displayName!),
      trailing: trailing,
    );
  }
}