import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:word_learn/model/firestore_manager.dart';
import 'package:word_learn/model/word.dart';

class DetailsPage extends StatefulWidget {
  final Word word;

  const DetailsPage(this.word, {Key? key}) : super(key: key);

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final wordController = TextEditingController();
  final translationController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    wordController.text = widget.word.word;
    translationController.text = widget.word.translation;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: wordController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'type here ...',
                  ),
                  onChanged: (text) {
                    setState(() {
                      widget.word.word = text;
                      _formKey.currentState!.validate();
                    });
                  },
                  onFieldSubmitted: (text) => _submitUpdate(),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Don\'t leave this empty'
                      : null,
                ),
                TextFormField(
                  controller: translationController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'type here ...',
                  ),
                  onChanged: (text) {
                    setState(() {
                      widget.word.translation = text;
                      _formKey.currentState!.validate();
                    });
                  },
                  onFieldSubmitted: (text) => _submitUpdate(),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Don\'t leave this empty'
                      : null,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        CollectionReference words =
                            FirebaseFirestore.instance.collection('words');
                        words.doc(widget.word.documentID).delete().then(
                            (value) {
                          print("User Deleted");
                          Navigator.pop(context);
                        }).catchError(
                            (error) => print("Failed to delete user: $error"));
                      },
                      icon: Icon(Icons.delete),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitUpdate() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Word Updated')),
      );
      FirestoreManager.updateWord(widget.word);
    } else {
      FirestoreManager.getWord(widget.word.documentID).then((value) {
        if (value == null) {
          // Word had no documentID
          return;
        }
        setState(() {
          widget.word.update(value);
          wordController.text = widget.word.word;
          translationController.text = widget.word.translation;
          _formKey.currentState!.validate();
        });
      });
    }
  }
}
