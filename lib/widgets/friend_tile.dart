import 'package:flutter/material.dart';
import 'package:word_learn/model/friend_model.dart';

import 'package:word_learn/view/components/bubble.dart';
import 'package:word_learn/view/components/clickable.dart';

class FriendTile extends StatelessWidget {
  final UserInfoModel friend;

  const FriendTile({Key? key, required this.friend}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Clickable(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Bubble(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_circle,
                size: 50.0,
                color: Colors.grey[200],
              ),
              const SizedBox(height: 10.0),
              Text(
                friend.displayName ?? '',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
