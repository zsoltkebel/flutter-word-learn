import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:word_learn/model/word.dart';

class DetailsPage extends StatelessWidget {
  final Word word;

  const DetailsPage(this.word, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(word.word),
              Text(word.translation),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      CollectionReference words =
                          FirebaseFirestore.instance.collection('words');
                      words
                          .doc(word.documentID)
                          .delete()
                          .then((value) {
                            print("User Deleted");
                            Navigator.pop(context);
                          })
                          .catchError((error) =>
                              print("Failed to delete user: $error"));
                    },
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
