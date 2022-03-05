import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:word_learn/model/firestore_manager.dart';
import 'package:word_learn/model/folder.dart';
import 'package:word_learn/model/word.dart';
import 'package:word_learn/view/add_page.dart';
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
  @override
  Widget build(BuildContext context) {
    print(widget.folder?.documentID);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder?.name ?? 'All words'),
        actions: [
          CupertinoSwitch(value: Word.reverse, onChanged: (value) {
            setState(() {
              Word.reverse = value;
            });
          })
        ],
      ),
      body: StreamBuilder(
        stream: widget.folder == null
            ? FirebaseFirestore.instance
                .collection('words')
                .orderBy('word')
                .snapshots()
            : FirebaseFirestore.instance
                .collection('words')
                .where('folderIDs', arrayContains: widget.folder!.documentID)
                // .orderBy('word')
                .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          print(snapshot.data);
          if (!snapshot.hasData) {
            print(snapshot.error);
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.red,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              Word word = Word.fromSnapshot(doc);
              return Dismissible(
                direction: DismissDirection.endToStart,
                key: UniqueKey(),
                onDismissed: (direction) {
                  // Remove the item from the data source.
                  setState(() {
                    // immediately remove widget from tree
                    snapshot.data!.docs.removeAt(index);

                    FirestoreManager.deleteWordFull(word);
                  });

                  // Then show a snackbar
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Deleted "${word.word.truncateWithEllipsis(8)}"')));
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
                  title: Text(word.firstWord),
                  subtitle: Text(word.secondWord),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InfoIcons(
                        hasText: word.word.isNotEmpty,
                        hasRecording: word.storageRefToRec1 != null,
                      ),
                      const SizedBox(
                        height: 4.0,
                      ),
                      InfoIcons(
                        hasText: word.translation.isNotEmpty,
                        hasRecording: word.storageRefToRec2 != null,
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DetailsPage(word)),
                    );
                  },
                ),
              );
            },
          );
        },
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
