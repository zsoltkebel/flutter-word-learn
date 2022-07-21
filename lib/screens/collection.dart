import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:word_learn/model/custom_user_info.dart';
import 'package:word_learn/model/firestore_manager.dart';
import 'package:word_learn/model/trans_collection.dart';
import 'package:word_learn/model/trans_entry.dart';
import 'package:word_learn/screens/collection_details_input.dart';
import 'package:word_learn/screens/entry_search/entry_search_delegate.dart';
import 'package:word_learn/screens/entry_search/entry_tile.dart';
import 'package:word_learn/screens/user_search/user_search_delegate.dart';
import 'package:word_learn/screens/user_search/share_toggle_button.dart';
import 'package:word_learn/screens/user_search/user_tile.dart';
import 'package:word_learn/view/add_page.dart';
import 'package:word_learn/extension/extensions.dart';
import 'dart:developer' as developer;

class CollectionPage extends StatefulWidget {
  final TransCollection folder;

  const CollectionPage({
    Key? key,
    required this.folder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  TransCollection? collection;
  List<QueryDocumentSnapshot>? entryDocs;

  @override
  initState() {
    super.initState();
    collection ??= widget.folder;
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Trying to load collection with id: ${widget.folder.id}');
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final reverse = collection?.reverseFor.contains(uid) ?? false;
    final stream =
        collection?.entries?.orderBy(reverse ? 'text-2' : 'text-1').snapshots();
    return WillPopScope(
      onWillPop: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        return Future.value(true);
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: GestureDetector(
                onTap: _navigateToDetailsChange,
                child: Text(collection?.name ?? r'¯\_(ツ)_/¯'),
              ),
              actions: [
                IconButton(
                    onPressed: _searchEntry, icon: const Icon(Icons.search)),
                IconButton(
                    onPressed: _searchUser,
                    icon: const Icon(Icons.person_add_alt)),
                IconButton(
                    onPressed: _onCreatePressed, icon: const Icon(Icons.add))
              ],
              floating: true,
            ),
            CupertinoSliverRefreshControl(
              onRefresh: () async {
                await _reloadCollection();
              },
            ),
            StreamBuilder<QuerySnapshot>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.teal),
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    developer.log('Error while fetching data from Firestore',
                        error: snapshot.error);
                    return const SliverFillRemaining(
                      child: Center(
                          child: Text('Oops... Something went wrong :/')),
                    );
                  }
                  entryDocs = snapshot.data!.docs;
                  developer
                      .log('Collection with id: ${widget.folder.id} is loaded');
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final doc = snapshot.data!.docs[index];
                        TransEntry entry = TransEntry.fromSnapshot(doc);
                        return Dismissible(
                          direction: DismissDirection.endToStart,
                          key: UniqueKey(),
                          onDismissed: (direction) {
                            // Remove the item from the data source.
                            setState(() {
                              // immediately remove widget from tree
                              snapshot.data!.docs.removeAt(index);

                              FirestoreManager.deleteEntryAndFiles(
                                  widget.folder, entry);
                            });

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Deleted "${entry.text1.truncateWithEllipsis(8)}"')));
                          },
                          background: Container(
                            color: Colors.red,
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          child: EntryTile(
                            entry: entry,
                            collection: collection!,
                          ),
                        );
                      },
                      childCount: snapshot.data?.docs.length,
                    ),
                  );
                }),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(_createRoute());
          },
          label: const Text('New Word'),
          icon: const Icon(
            Icons.add,
            semanticLabel: 'helo',
          ),
        ),
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => AddPage(
        folder: widget.folder,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  void _onCreatePressed() {
    Navigator.of(context).push(_createRoute());
  }

  void _navigateToDetailsChange() async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CollectionDetailsInputPage(
              collection: collection,
            )));
    _reloadCollection();
  }

  void _displayAddOrRemoveSnack(BuildContext context, bool added, String name) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(added
              ? 'Shared with $name'
              : 'Removed $name from this collection'),
        ),
      );
  }

  Future _reloadCollection() async {
    final doc = await FirebaseFirestore.instance
        .collection('folders')
        .doc(collection!.id)
        .get();
    setState(() {
      collection = TransCollection.fromSnapshot(doc);
      print('updated');
      print(collection);
    });
  }

  void _searchEntry() {
    showSearch(
        context: context,
        delegate: EntrySearchDelegate(
            collection: collection!,
            entries: entryDocs?.map(TransEntry.fromSnapshot).toList() ?? []));
  }

  void _searchUser() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    final users = {
      for (var doc in snapshot.docs) doc.id: CustomUserInfo.fromSnapshot(doc)
    };
    showSearch(
      context: context,
      delegate: UserSearchDelegate(
        users: users,
        selectedUids: widget.folder.visibleFor,
        suggestionBuilder: () {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Sharing'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.folder.visibleFor.length,
                  itemBuilder: (context, index) {
                    final usr = users[widget.folder.visibleFor[index]];
                    if (usr == null ||
                        usr.uid == FirebaseAuth.instance.currentUser?.uid) {
                      return Container(); // Do not show current user among results
                    }
                    return UserTile(
                      usr: usr,
                      trailing: ShareToggleButton(
                          uid: usr.uid,
                          isCollaborator:
                              widget.folder.visibleFor.contains(usr.uid),
                          collection: widget.folder,
                          onSharingChanged: (shared) =>
                              _displayAddOrRemoveSnack(
                                  context, shared, usr.displayName!)),
                    );
                  },
                ),
              ),
            ],
          );
        },
        actionBuilder: (usr) {
          final isCollaborator = widget.folder.visibleFor.contains(usr.uid);
          return ShareToggleButton(
              uid: usr.uid,
              isCollaborator: isCollaborator,
              collection: widget.folder,
              onSharingChanged: (shared) =>
                  _displayAddOrRemoveSnack(context, shared, usr.displayName!));
        },
      ),
    );
  }
}
