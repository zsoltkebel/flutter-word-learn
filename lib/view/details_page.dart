import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:word_learn/model/firebase_storage_helper.dart';
import 'package:word_learn/model/firestore_manager.dart';
import 'package:word_learn/model/word.dart';
import 'package:word_learn/non-ui/sound_player.dart';
import 'package:word_learn/view/components/display.dart';
import 'package:word_learn/view/components/info_icons.dart';
import 'package:word_learn/view/components/info_section.dart';

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

  SoundPlayer player = SoundPlayer();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    wordController.text = widget.word.word;
    translationController.text = widget.word.translation;

    FirebaseStorageHelper.downloadFiles(
      storageRefs: [widget.word.storageRefToRec1, widget.word.storageRefToRec2],
    ).then((recordings) {
      setState(() {
        widget.word.rec1 = recordings[0];
        widget.word.rec2 = recordings[1];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text('Word'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InfoSection(
                  caption: 'word',
                  hasText: widget.word.word.isNotEmpty,
                  hasRecording: widget.word.storageRefToRec1 != null,
                ),
                Display(
                  recording: widget.word.rec1,
                  text: widget.word.word,
                  onTextChanged: (text) {
                    setState(() {
                      widget.word.word = text;
                    });
                  },
                ),
                InfoSection(
                  caption: 'translation',
                  hasText: widget.word.translation.isNotEmpty,
                  hasRecording: widget.word.storageRefToRec2 != null,
                ),
                Display(
                  recording: widget.word.rec2,
                  text: widget.word.translation,
                  onTextChanged: (text) {
                    setState(() {
                      widget.word.translation = text;
                    });
                  },
                ),
                const SizedBox(
                  height: 140.0,
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
