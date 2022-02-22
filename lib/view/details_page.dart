import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:word_learn/model/firebase_storage_helper.dart';
import 'package:word_learn/model/firestore_manager.dart';
import 'package:word_learn/model/word.dart';
import 'package:word_learn/non-ui/sound_player.dart';
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

    FirebaseStorageHelper.downloadRecording1(word: widget.word);
    FirebaseStorageHelper.downloadRecording2(word: widget.word);
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InfoSection(
                  caption: 'word',
                  hasText: widget.word.word.isNotEmpty,
                  hasRecording: widget.word.storageRefToRec1 != null,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: wordController,
                        minLines: 1,
                        maxLines: 10,
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
                    ),
                    isLoading
                        ? const CupertinoActivityIndicator()
                        : IconButton(
                            onPressed: () async {
                              if (widget.word.rec1 != null) {
                                await player.setFile(
                                    path: widget.word.rec1!.path);
                                await player.play();
                              } else {
                                String url = await FirebaseStorage.instance
                                    .ref(widget.word.storageRefToRec1)
                                    .getDownloadURL();
                                print(url);
                                setState(() {
                                  isLoading = true;
                                });
                                await player.setURL(url);
                                await player.play();
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                            icon: Icon(Icons.record_voice_over)),
                  ],
                ),
                InfoSection(
                  caption: 'translation',
                  hasText: widget.word.translation.isNotEmpty,
                  hasRecording: widget.word.storageRefToRec2 != null,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: translationController,
                        minLines: 1,
                        maxLines: 10,
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
                    ),
                    isLoading
                        ? const CupertinoActivityIndicator()
                        : IconButton(
                            onPressed: () async {
                              if (widget.word.rec2 != null) {
                                await player.setFile(
                                    path: widget.word.rec2!.path);
                                await player.play();
                              } else {
                                String url = await FirebaseStorage.instance
                                    .ref(widget.word.storageRefToRec2)
                                    .getDownloadURL();
                                print(url);
                                setState(() {
                                  isLoading = true;
                                });
                                await player.setURL(url);
                                await player.play();
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                            icon: Icon(Icons.record_voice_over)),
                  ],
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
