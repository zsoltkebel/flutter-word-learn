import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:word_learn/model/firebase_storage_helper.dart';
import 'package:word_learn/model/firestore_manager.dart';
import 'package:word_learn/model/trans_collection.dart';
import 'package:word_learn/model/trans_entry.dart';
import 'package:word_learn/view/components/info_section.dart';
import 'package:word_learn/extension/extensions.dart';
import 'package:word_learn/view/components/recorder_ui.dart';

class AddPage extends StatefulWidget {
  final TransCollection? folder;

  const AddPage({
    Key? key,
    this.folder,
  }) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  CollectionReference words = FirebaseFirestore.instance.collection('words');

  final wordController = TextEditingController();
  final translationController = TextEditingController();
  late FocusNode translationFieldFocusNode;

  final _formKey = GlobalKey<FormState>();

  File? recording1;
  File? recording2;

  TransEntry entry = TransEntry(text1: '', text2: '');

  void _submit() {
    if (wordController.text.isNotEmpty &&
        translationController.text.isNotEmpty) {

      entry.text1 = wordController.text;
      entry.text2 = translationController.text;

      FirestoreManager.setEntry(folder: widget.folder, entry: entry)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Added "${entry.text1.truncateWithEllipsis(8)}"')));
        Navigator.pop(context);
      }).catchError((error) {
        print("Failed to set entry: $error");
      });
      //     .then((doc) async {
      //   print(doc);
      //   print('uploaded: ${doc.id}');
      //   entry = entry.copyWith(id: doc.id);
      //   FirebaseStorageHelper.uploadFiles(
      //     fileRefMap: {
      //       recording1: 'recordings/${entry.id!}-w.m4a',
      //       recording2: 'recordings/${entry.id!}-t.m4a',
      //     },
      //   ).then((storageRefs) {
      //     entry.storageRef1 = storageRefs[0];
      //     entry.storageRef2 = storageRefs[1];
      //     FirestoreManager.setEntry(folder: widget.folder, entry: entry);
      //   });
      //
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //       content:
      //           Text('Added "${entry.text1.truncateWithEllipsis(8)}"')));
      //   Navigator.pop(context);
      // }).catchError((error) => print("Failed to add user: $error"));
    } else {
      // just return
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();

    wordController.addListener(() => setState(() {}));
    translationController.addListener(() => setState(() {}));
    translationFieldFocusNode = FocusNode();
  }

  @override
  void dispose() {
    translationFieldFocusNode.dispose();
    // text editing controllers are disposed of in InputWidget
    // wordController.dispose();
    // translationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text('New Word'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoSection(
                caption: widget.folder!.language1,
                hasText: wordController.text.isNotEmpty,
                hasRecording: recording1 != null,
              ),
              RecorderUI(
                // pathToAudioFile: ,
                textEditingController: wordController,
                textInputAction: TextInputAction.next,
                onRecordingFileChanged: (file) {
                  setState(() {
                    entry.recording1 = file;
                    recording1 = file;
                  });
                  print('recording1 = $recording1');
                },
                // onFieldSubmitted: widget.onFieldSubmitted,
              ),
              const SizedBox(height: 20.0),
              InfoSection(
                caption: widget.folder!.language2,
                hasText: translationController.text.isNotEmpty,
                hasRecording: recording2 != null,
              ),
              RecorderUI(
                // pathToAudioFile: ,
                textEditingController: translationController,
                onRecordingFileChanged: (file) {
                  setState(() {
                    entry.recording2 = file;
                    recording2 = file;
                  });
                  print('recording2 = $recording2');
                },
                onFieldSubmitted: (text) => _submit(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submit,
        label: Text(wordController.text.isNotEmpty &&
                translationController.text.isNotEmpty
            ? 'Done'
            : 'Go Back'),
        icon: Icon(wordController.text.isNotEmpty &&
                translationController.text.isNotEmpty
            ? Icons.done
            : Icons.arrow_back_ios),
        backgroundColor: wordController.text.isNotEmpty &&
                translationController.text.isNotEmpty
            ? Theme.of(context).primaryColor
            : Colors.grey,
      ),
    );
  }
}
