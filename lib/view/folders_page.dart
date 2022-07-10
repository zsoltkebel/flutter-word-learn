import 'dart:ui';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:word_learn/model/firestore_manager.dart';
import 'package:word_learn/model/folder.dart';
import 'package:word_learn/model/user_data.dart';
import 'package:word_learn/view/components/clickable.dart';
import 'package:word_learn/widgets/collection_tile.dart';
import 'package:word_learn/widgets/friends_sliver.dart';
import 'package:word_learn/widgets/section_header.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class FoldersPage extends StatefulWidget {
  final UserData? userData;

  const FoldersPage({
    Key? key,
    this.userData,
  }) : super(key: key);

  @override
  _FoldersPageState createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage>
    with AutomaticKeepAliveClientMixin<FoldersPage> {
  final textEditingController = TextEditingController();

  int selectedGroup = 0;
  bool scrollable = true;
  double maxh = 0;

  late final scrollController = AutoScrollController(
      //add this for advanced viewport boundary. e.g. SafeArea
      viewportBoundaryGetter: () =>
          Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),

      //choose vertical/horizontal
      axis: Axis.vertical,

      //this given value will bring the scroll offset to the nearest position in fixed row height case.
      //for variable row height case, you can still set the average height, it will try to get to the relatively closer offset
      //and then start searching.
      suggestedRowHeight: 200);

  @override
  Widget build(BuildContext context) {
    List<Widget> slivers = [
      SliverAppBar(
        floating: true,
        pinned: true,
        toolbarHeight: 0.0,
        // backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      SliverStickyHeader(
        header: _buildTop(),
      ),
    ];

    //TODO friends section slivers
    slivers.add(SliverStickyHeader(
      header: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SectionHeader(
          title: 'Friends',
          trailing: Clickable(
            onTap: () {
              final controller = TextEditingController(
                  text: FirebaseAuth.instance.currentUser?.displayName);
              showCupertinoDialog<void>(
                context: context,
                builder: (BuildContext context) => CupertinoAlertDialog(
                  title: const Text('Name'),
                  content: CupertinoTextField(
                    autofocus: true,
                    controller: controller,
                  ),
                  actions: <CupertinoDialogAction>[
                    CupertinoDialogAction(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      child: const Text('Add'),
                      onPressed: () async {
                        final snap = await FirebaseFirestore.instance
                            .collection('users')
                            .where('display-name', isEqualTo: controller.text)
                            .limit(1)
                            .get();
                        if (snap.docs.length == 1) {
                          print('got user: ${snap.docs[0].id}');
                          FirestoreManager.addFriend(
                              person1: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid),
                              person2: snap.docs[0].reference);
                        } else {
                          print('no user with name');
                        }
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
              );
            },
            child: Text(
              'Add',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            // child: Icon(
            //   Icons.add,
            //   color: Colors.grey[400],
            // ),
          ),
        ),
      ),
      sliver: SliverFriendsGrid(
        uid: widget.userData?.uid,
      ),
    ));

    //TODO all section
    slivers.addAll(_buildFoldersSection(context: context));
    slivers.add(SliverFillRemaining());

    return CupertinoPageScaffold(
      child: CustomScrollView(
        controller: scrollController,
        slivers: slivers,
      ),
    );
  }

  Widget _buildListTile(Folder folder) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 7.0),
        child: CollectionTile(folder: folder,),
      );

  Widget _buildTop() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Your collection',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: Color(0xFF9FA2A8)),
                  ),
                  Clickable(
                    onTap: () {
                      final controller = TextEditingController(
                          text: FirebaseAuth.instance.currentUser?.displayName);
                      showCupertinoDialog<void>(
                        context: context,
                        builder: (BuildContext context) => CupertinoAlertDialog(
                          title: const Text('Name'),
                          content: CupertinoTextField(
                            autofocus: true,
                            controller: controller,
                          ),
                          actions: <CupertinoDialogAction>[
                            CupertinoDialogAction(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              child: const Text('Save'),
                              onPressed: () async {
                                await FirebaseAuth.instance.currentUser
                                    ?.updateDisplayName(controller.text);
                                final user = FirebaseAuth.instance.currentUser!;
                                FirestoreManager.updateUserInfo(
                                  uid: user.uid,
                                  displayName: user.displayName,
                                  photoURL: user.photoURL,
                                );
                                setState(() {});
                                Navigator.pop(context);
                              },
                            )
                          ],
                        ),
                      );
                    },
                    child: Text(
                      FirebaseAuth.instance.currentUser?.displayName ?? 'User',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontSize: 38.0),
                    ),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
            Clickable(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
              },
              child: Badge(
                badgeColor: Theme.of(context).colorScheme.primary,
                position: BadgePosition.topEnd(top: 0.0, end: 0.0),
                child: Icon(
                  Icons.account_circle,
                  size: 50.0,
                  color: Colors.grey[200],
                ),
              ),
            ),
          ],
        ),
      );

  @override
  bool get wantKeepAlive => true;

  List<Widget> _buildFoldersSection({required BuildContext context}) {
    return [
      SliverStickyHeader(
        header: AutoScrollTag(
          key: ValueKey(0),
          index: 0,
          controller: scrollController,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  title: 'Folders',
                  trailing: Clickable(
                    child: Text(
                      'Create',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22.0,
                    vertical: 10.0,
                  ),
                  child: CupertinoSlidingSegmentedControl(
                    children: {
                      0: Text('All'),
                      1: Text('Shared'),
                      2: Text('Private'),
                    },
                    groupValue: selectedGroup,
                    onValueChanged: (index) {
                      setState(() {
                        selectedGroup = index as int;

                        setState(() {
                          scrollable = true;
                          maxh = 0;
                          print('value changed');
                        });
                        scrollController
                            .scrollToIndex(0,
                                preferPosition: AutoScrollPosition.begin)
                            .then((value) {
                          setState(() {
                            scrollable = false;
                          });
                        });
                      });
                    },
                  ),
                )
              ],
            ),
          ),
        ),
        sliver: StreamBuilder<QuerySnapshot>(
          stream: _getFolderQuery(selectedGroup),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                !snapshot.hasData) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator.adaptive(),
                ),
              );
            } else {
              // got the data
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final folder =
                        Folder.fromSnapshot(snapshot.data!.docs[index]);
                    return _buildListTile(folder);
                  },
                  childCount: snapshot.data!.docs.length,
                ),
              );
            }
          },
        ),
      ),
    ];
  }

  Stream<QuerySnapshot> _getFolderQuery(int option) {
    switch (option) {
      case 1:
        return FirebaseFirestore.instance
            .collection('folders')
            .where('shared', isEqualTo: true)
            .snapshots();
      case 2:
        return FirebaseFirestore.instance
            .collection('folders')
            .where('shared', isEqualTo: false)
            .snapshots();
      default:
        return FirebaseFirestore.instance.collection('folders').snapshots();
    }
  }
}
