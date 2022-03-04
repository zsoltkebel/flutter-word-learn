
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:word_learn/extension/extensions.dart';
import 'package:word_learn/model/firebase_storage_helper.dart';
import 'package:word_learn/model/firestore_manager.dart';
import 'package:word_learn/model/word.dart';
import 'package:word_learn/non-ui/sound_player.dart';
import 'package:word_learn/view/components/display.dart';
import 'package:word_learn/view/components/info_section.dart';
import 'package:word_learn/view/components/recorder_ui.dart';

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

  bool editing = false;

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
    bool contentDownloading =
        (widget.word.storageRefToRec1 != null && widget.word.rec1 == null) ||
            (widget.word.storageRefToRec2 != null && widget.word.rec2 == null);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(editing ? 'Editing' : 'Word'),
        actions: [
          IconButton(
            onPressed: contentDownloading
                ? null
                : () {
                    setState(() {
                      editing = !editing;
                    });
                  },
            icon: contentDownloading
                ? const CircularProgressIndicator.adaptive()
                : (editing ? const Icon(Icons.close) : const Icon(Icons.edit)),
          ),
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
                  hasRecording: widget.word.rec1 != null,
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: editing
                      ? RecorderUI(
                          // text: widget.word.word,
                          textEditingController: wordController,
                          recording: widget.word.rec1,
                          onRecordingFileChanged: (file) {
                            setState(() {
                              widget.word.rec1 = file;
                            });
                          },
                          onFieldSubmitted: (text) => _submit(),
                        )
                      : Display(
                          recording: widget.word.rec1,
                          text: widget.word.word,
                          onTextChanged: (text) {
                            setState(() {
                              widget.word.word = text;
                            });
                          },
                        ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                InfoSection(
                  caption: 'translation',
                  hasText: widget.word.translation.isNotEmpty,
                  hasRecording: widget.word.rec2 != null,
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: editing
                      ? RecorderUI(
                          // text: widget.word.translation,
                          textEditingController: translationController,
                          recording: widget.word.rec2,
                          onRecordingFileChanged: (file) {
                            setState(() {
                              widget.word.rec2 = file;
                            });
                          },
                          onFieldSubmitted: (text) => _submit(),
                        )
                      : Display(
                          recording: widget.word.rec2,
                          text: widget.word.translation,
                          onTextChanged: (text) {
                            setState(() {
                              widget.word.translation = text;
                            });
                          },
                        ),
                ),
                // const SizedBox(
                //   height: 140.0,
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     IconButton(
                //       onPressed: () {
                //         CollectionReference words =
                //             FirebaseFirestore.instance.collection('words');
                //         words.doc(widget.word.documentID).delete().then(
                //             (value) {
                //           print("User Deleted");
                //           Navigator.pop(context);
                //         }).catchError(
                //             (error) => print("Failed to delete user: $error"));
                //       },
                //       icon: Icon(Icons.delete),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    //TODO! cleanup logic
    if (wordController.text.isNotEmpty &&
        translationController.text.isNotEmpty) {
      print('updating ${widget.word.documentID}');
      widget.word.word = wordController.text;
      widget.word.translation = translationController.text;
      FirestoreManager.updateWord(widget.word).then((doc) {
        FirebaseStorageHelper.uploadFiles(
          fileRefMap: {
            widget.word.rec1: 'recordings/${widget.word.documentID!}-w.m4a',
            widget.word.rec2: 'recordings/${widget.word.documentID!}-t.m4a',
          },
        ).then((storageRefs) {
          if (storageRefs[0] == null) {
            FirebaseStorageHelper.deleteFile(
                path: widget.word.storageRefToRec1);
          }
          if (storageRefs[1] == null) {
            FirebaseStorageHelper.deleteFile(
                path: widget.word.storageRefToRec2);
          }
          widget.word.storageRefToRec1 = storageRefs[0];
          widget.word.storageRefToRec2 = storageRefs[1];
          FirestoreManager.updateWord(widget.word);
        });
        setState(() {
          editing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Edited "${widget.word.word.truncateWithEllipsis(8)}"')));
      });
    }
  }
}
