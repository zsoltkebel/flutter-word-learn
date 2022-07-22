import 'package:flutter/material.dart';
import 'package:word_learn/model/trans_collection.dart';
import 'package:word_learn/model/trans_entry.dart';
import 'package:word_learn/screens/entry_search/entry_tile.dart';

class EntrySearchDelegate extends SearchDelegate {
  final TransCollection collection;
  final List<TrEntry> entries;

  EntrySearchDelegate({required this.collection, required this.entries});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return null;
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return BackButton(
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filter =
        query.toLowerCase(); //TODO strip of special characters and accents
    final matches = List.of(entries.where((entry) =>
        entry.text1.toLowerCase().contains(filter) ||
        entry.text2.toLowerCase().contains(filter)));

    return ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) {
          return EntryTile(entry: matches[index], collection: collection);
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isNotEmpty) {
      return buildResults(context);
    }
    return Container();
  }
}
