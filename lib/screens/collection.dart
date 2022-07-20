import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:word_learn/model/firestore_manager.dart';
import 'package:word_learn/model/trans_collection.dart';
import 'package:word_learn/model/trans_entry.dart';
import 'package:word_learn/screens/collection_details_input.dart';
import 'package:word_learn/screens/user_selection.dart';
import 'package:word_learn/view/add_page.dart';
import 'package:word_learn/view/components/info_icons.dart';
import 'package:word_learn/view/details_page.dart';
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
  late bool reverse =
      widget.folder.reverseFor.contains(FirebaseAuth.instance.currentUser!.uid);

  @override
  Widget build(BuildContext context) {
    developer.log('Trying to load collection with id: ${widget.folder.id}');

    final stream = widget.folder.entries
        ?.orderBy(reverse ? 'text-2' : 'text-1')
        .snapshots();
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
                onTap: _onChangeDetailsPressed,
                child: Text(widget.folder.name),
              ),
              actions: [
                IconButton(
                    onPressed: _onSharePressed,
                    icon: const Icon(Icons.person_add_alt)),
                IconButton(
                    onPressed: _onReversePressed,
                    icon: const Icon(Icons.swap_vert)),
                IconButton(
                    onPressed: _onCreatePressed, icon: const Icon(Icons.add))
              ],
              floating: true,
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
                  developer
                      .log('Collection with id: ${widget.folder.id} is loaded');
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final doc = snapshot.data!.docs[index];
                        TransEntry word =
                            TransEntry.fromSnapshot(doc);
                        return Dismissible(
                          direction: DismissDirection.endToStart,
                          key: UniqueKey(),
                          onDismissed: (direction) {
                            // Remove the item from the data source.
                            setState(() {
                              // immediately remove widget from tree
                              snapshot.data!.docs.removeAt(index);

                              FirestoreManager.deleteEntryAndFiles(
                                  widget.folder, word);
                            });

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Deleted "${word.text1.truncateWithEllipsis(8)}"')));
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
                          child: ListTile(
                            title: Text(reverse ? word.text2 : word.text1),
                            subtitle: Text(reverse ? word.text1 : word.text2),
                            trailing: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InfoIcons(
                                  hasText: word.text1.isNotEmpty,
                                  hasRecording: word.storageRef1 != null,
                                ),
                                const SizedBox(
                                  height: 4.0,
                                ),
                                InfoIcons(
                                  hasText: word.text2.isNotEmpty,
                                  hasRecording: word.storageRef2 != null,
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DetailsPage(
                                          word,
                                          folder: widget.folder,
                                        )),
                              );
                            },
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

  void _onReversePressed() {
    setState(() {
      reverse = !reverse;
    });
    reverse
        ? FirebaseFirestore.instance
            .collection("folders")
            .doc(widget.folder.id)
            .update({
            "reverse-for":
                FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
          })
        : FirebaseFirestore.instance
            .collection("folders")
            .doc(widget.folder.id)
            .update({
            "reverse-for":
                FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
          });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Primary language: ${reverse ? widget.folder.language2 : widget.folder.language1}')));
  }

  void _onSharePressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserSelectionScreen(
          uids: Set.from(widget.folder.visibleFor ?? []),
          onSelected: (users) {
            FirebaseFirestore.instance
                .collection("folders")
                .doc(widget.folder.id)
                .update({"can-view": users.map((user) => user.uid).toList()});
            widget.folder.visibleFor = users.map((u) => u.uid).toList();
          },
        ),
      ),
    );
  }

  void _onCreatePressed() {
    Navigator.of(context).push(_createRoute());
  }

  void _onChangeDetailsPressed() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CollectionDetailsInputPage(
              collection: widget.folder,
            )));
  }
}
