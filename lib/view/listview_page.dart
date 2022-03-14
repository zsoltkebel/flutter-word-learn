import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:word_learn/model/firestore_manager.dart';
import 'package:word_learn/model/folder.dart';
import 'package:word_learn/model/translation_entry.dart';
import 'package:word_learn/view/add_page.dart';
import 'package:word_learn/view/components/bubble.dart';
import 'package:word_learn/view/components/clickable.dart';
import 'package:word_learn/view/components/info_icons.dart';
import 'package:word_learn/view/details_page.dart';
import 'package:word_learn/extension/extensions.dart';

class ListViewPage extends StatefulWidget {
  final Folder? folder;

  const ListViewPage({
    Key? key,
    this.folder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ListViewPageState();
}

class _ListViewPageState extends State<ListViewPage> {
  bool reverse = false;

  @override
  Widget build(BuildContext context) {
    print(widget.folder?.id);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            // Provide a standard title.
            title: Text(widget.folder?.name ?? ''),
            // Allows the user to reveal the app bar if they begin scrolling
            // back up the list of items.
            actions: [

            ],
            floating: true,
            // Display a placeholder widget to visualize the shrinking size.
            // flexibleSpace: Center(
            //   child: Text('hello'),
            // ),
            // Make the initial height of the SliverAppBar larger than normal.
            // expandedHeight: 200,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(14.0),
            sliver: SliverGrid(
              delegate: SliverChildListDelegate([
                Clickable(
                  child: Bubble(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Reversed'),
                        CupertinoSwitch(
                            value: reverse,
                            onChanged: (value) {
                              setState(() {
                                reverse = value;
                              });
                            }),
                      ],
                    ),
                  ),
                ),
                Clickable(
                  onTap: () => Navigator.of(context).push(_createRoute()),
                  child: Bubble(
                    child: Icon(Icons.add),
                  ),
                ),
              ]),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 80.0,
                crossAxisSpacing: 14.0,
                mainAxisSpacing: 14.0
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
              stream: widget.folder == null
                  ? FirebaseFirestore.instance
                      .collection('words')
                      .orderBy('word')
                      .snapshots()
                  : widget.folder!.entries?.snapshots(),
              builder: (context, snapshot) {
                print(snapshot.data);
                if (!snapshot.hasData) {
                  print(snapshot.error);
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final doc = snapshot.data!.docs[index];
                      TranslationEntry word =
                          TranslationEntry.fromSnapshot(doc);
                      return Dismissible(
                        direction: DismissDirection.endToStart,
                        key: UniqueKey(),
                        onDismissed: (direction) {
                          // Remove the item from the data source.
                          setState(() {
                            // immediately remove widget from tree
                            snapshot.data!.docs.removeAt(index);

                            FirestoreManager.deleteEntryAndFiles(
                                widget.folder!, word);
                          });

                          // Then show a snackbar
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Deleted "${word.text1.truncateWithEllipsis(8)}"')));
                        },
                        background: Container(
                          color: Colors.red,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20.0),
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
                                        folder: widget.folder!,
                                      )),
                            );
                          },
                        ),
                      );
                    },
                    // Builds 1000 ListTiles
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
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => AddPage()),
            // );
          },
          label: Text('New Word'),
          icon: Icon(
            Icons.add,
            semanticLabel: 'helo',
          )),
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
}
