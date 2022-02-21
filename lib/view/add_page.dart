import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:word_learn/model/word.dart';
import 'package:word_learn/view/components/input_widget.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  CollectionReference words = FirebaseFirestore.instance.collection('words');

  final wordController = TextEditingController();
  final translationController = TextEditingController();
  late FocusNode translationFieldFocusNode;

  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (wordController.text.isNotEmpty &&
        translationController.text.isNotEmpty) {
      Word word = Word(wordController.text, translationController.text);
      words.add(word.toMap()).then((value) {
        print("User Added");
        Navigator.pop(context);
      }).catchError((error) => print("Failed to add user: $error"));
    } else {
      // just return
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    translationFieldFocusNode = FocusNode();
  }

  @override
  void dispose() {
    translationFieldFocusNode.dispose();
    wordController.dispose();
    translationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('New Word'),
      // ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InputWidget(
                  label: 'WORD',
                  controller: wordController,
                  // pathToAudioFile: '${getApplicationDocumentsDirectory()}/voice1.m4a',
                  onFieldSubmitted: (text) =>
                      translationFieldFocusNode.requestFocus(),
                ),
                const SizedBox(height: 20.0),
                InputWidget(
                  label: 'TRANSLATION',
                  controller: translationController,
                  // pathToAudioFile: '${getApplicationDocumentsDirectory()}/voice2.aac',
                  focusNode: translationFieldFocusNode,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (text) => _submit(),
                ),
              ],
            ),
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
