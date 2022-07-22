import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:word_learn/extension/extensions.dart';
import 'package:word_learn/model/firebase_storage_helper.dart';
import 'package:word_learn/model/firestore_manager.dart';
import 'package:word_learn/model/trans_collection.dart';
import 'package:word_learn/model/trans_entry.dart';
import 'package:word_learn/non-ui/sound_player.dart';
import 'package:word_learn/view/components/display.dart';
import 'package:word_learn/view/components/info_section.dart';
import 'package:word_learn/view/components/recorder_ui.dart';

class DetailsPage extends StatefulWidget {
  final TransCollection folder;
  final TrEntry entry;

  const DetailsPage(this.entry, {Key? key, required this.folder})
      : super(key: key);

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

    wordController.text = widget.entry.text1;
    translationController.text = widget.entry.text2;

    FirebaseStorageHelper.downloadFiles(
      storageRefs: [widget.entry.storageRef1, widget.entry.storageRef2],
    ).then((recordings) {
      setState(() {
        widget.entry.recording1 = recordings[0];
        widget.entry.recording2 = recordings[1];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool contentDownloading = (widget.entry.storageRef1 != null &&
            widget.entry.recording1 == null) ||
        (widget.entry.storageRef2 != null && widget.entry.recording2 == null);
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
                  hasText: widget.entry.text1.isNotEmpty,
                  hasRecording: widget.entry.recording1 != null,
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: editing
                      ? RecorderUI(
                          // text: widget.word.word,
                          textEditingController: wordController,
                          recording: widget.entry.recording1,
                          onRecordingFileChanged: (file) {
                            setState(() {
                              widget.entry.recording1 = file;
                            });
                          },
                          onFieldSubmitted: (text) => _submit(),
                        )
                      : Display(
                          recording: widget.entry.recording1,
                          text: widget.entry.text1,
                          onTextChanged: (text) {
                            setState(() {
                              widget.entry.text1 = text;
                            });
                          },
                        ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                InfoSection(
                  caption: 'translation',
                  hasText: widget.entry.text2.isNotEmpty,
                  hasRecording: widget.entry.recording2 != null,
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: editing
                      ? RecorderUI(
                          // text: widget.word.translation,
                          textEditingController: translationController,
                          recording: widget.entry.recording2,
                          onRecordingFileChanged: (file) {
                            setState(() {
                              widget.entry.recording2 = file;
                            });
                          },
                          onFieldSubmitted: (text) => _submit(),
                        )
                      : Display(
                          recording: widget.entry.recording2,
                          text: widget.entry.text2,
                          onTextChanged: (text) {
                            setState(() {
                              widget.entry.text2 = text;
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
      print('updating ${widget.entry.id}');
      widget.entry.text1 = wordController.text;
      widget.entry.text2 = translationController.text;

      FirestoreManager.setEntry(folder: widget.folder, entry: widget.entry)
          .then((value) {
        setState(() {
          editing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Edited "${widget.entry.text1.truncateWithEllipsis(8)}"')));
      });
    }
  }
}
