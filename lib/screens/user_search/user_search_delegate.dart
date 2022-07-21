import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:word_learn/model/custom_user_info.dart';
import 'dart:developer';

import 'package:word_learn/screens/user_search/user_tile.dart';

typedef ActionBuilder = Widget Function(CustomUserInfo usr);
typedef SuggestionBuilder = Widget Function();

/// Custom SearchDelegate to query users.
/// Functionality can be tweaked by providing an action and suggestion builder.
class UserSearchDelegate extends SearchDelegate {
  final Map<String, CustomUserInfo> users;
  final List<String> selectedUids;
  final ActionBuilder? actionBuilder;
  final SuggestionBuilder? suggestionBuilder;

  UserSearchDelegate({
    required this.users,
    required this.selectedUids,
    this.actionBuilder,
    this.suggestionBuilder,
  });

  @override
  String get searchFieldLabel => 'Search for people';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      Offstage(
        offstage: query.isEmpty,
        child: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return BackButton(
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final matches = List.of(users.values.where((user) =>
        user.displayName!.toLowerCase().contains(query.toLowerCase())));

    return ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final usr = matches[index];
          if (usr.uid == FirebaseAuth.instance.currentUser?.uid) {
            return Container(); // Do not show current user among results
          }
          return UserTile(
            usr: usr,
            trailing: actionBuilder?.call(usr),
          );
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isNotEmpty) {
      return buildResults(context);
    }
    // Use search suggestion area to display current collaborators
    log('Building suggestions');
    return suggestionBuilder?.call() ?? buildResults(context);
  }
}
