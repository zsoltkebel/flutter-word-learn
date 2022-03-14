import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:word_learn/model/folder.dart';
import 'package:word_learn/model/translation_entry.dart';
import 'package:word_learn/view/components/bubble.dart';
import 'package:word_learn/view/components/clickable.dart';
import 'package:word_learn/view/listview_page.dart';

class FoldersPage extends StatefulWidget {
  const FoldersPage({Key? key}) : super(key: key);

  @override
  _FoldersPageState createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
  final textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('folders').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.red,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(14.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14.0,
                mainAxisSpacing: 14.0,
              ),
              itemCount: snapshot.data!.docs.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Clickable(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListViewPage(
                            folder: null,
                          ),
                        ),
                      );
                    },
                    child: Bubble(
                      child: Center(
                          child: Text(
                        'All words',
                        style: Theme.of(context).textTheme.titleLarge,
                      )),
                    ),
                  );
                } else if (index == snapshot.data!.docs.length + 1) {
                  return Clickable(
                    onTap: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (_) => CupertinoAlertDialog(
                          title: Text('New folder'),
                          content: Column(
                            children: [
                              Text('Give a name'),
                              SizedBox(
                                height: 8.0,
                              ),
                              CupertinoTextField(
                                autofocus: true,
                                controller: textEditingController,
                              ),
                            ],
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: Text("Cancel"),
                              onPressed: () {
                                Navigator.pop(context);
                                textEditingController.text = '';
                              },
                            ),
                            CupertinoDialogAction(
                              child: Text("Add"),
                              isDefaultAction: true,
                              onPressed: () {
                                print(textEditingController.text);
                                FirebaseFirestore.instance
                                    .collection('folders')
                                    .doc()
                                    .set({'name': textEditingController.text});
                                Navigator.pop(context);
                                textEditingController.text = '';
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    child: Bubble(
                      child: Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(
                            Icons.add,
                            size: 30.0,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ),
                  );
                }
                final doc = snapshot.data!.docs[index - 1];
                final folder = Folder.fromSnapshot(doc);
                return Clickable(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListViewPage(
                          folder: folder,
                        ),
                      ),
                    );
                  },
                  child: Bubble(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          folder.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10.0,),
                        Text(
                          '${folder.language1} - ${folder.language2}',
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
