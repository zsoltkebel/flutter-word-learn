import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

class CreateCollectionPage extends StatefulWidget {
  const CreateCollectionPage({Key? key}) : super(key: key);

  @override
  State<CreateCollectionPage> createState() => _CreateCollectionPageState();
}

class _CreateCollectionPageState extends State<CreateCollectionPage> {
  bool missingDetails = true;

  final nameController = TextEditingController();
  final lang1Controller = TextEditingController();
  final lang2Controller = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    lang1Controller.dispose();
    lang2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Collection"),),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: _buildInputFields(),
            ),
            const Spacer(),
            Row(
              children: [
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(primary: Colors.red),
                    child: const Text("Cancel"),
                    onPressed: onCancelPressed,
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: OutlinedButton(
                    child: const Text("Create"),
                    onPressed: missingDetails ? null : onCreatePressed,
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputFields() => Column(
        children: [
          TextField(
            controller: nameController,
            onChanged: onValueChanged,
            autofocus: true,
            decoration: const InputDecoration(hintText: "Name"),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: lang1Controller,
                  onChanged: onValueChanged,
                  decoration: const InputDecoration(hintText: "Lang 1"),
                ),
              ),
              const SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: TextField(
                  controller: lang2Controller,
                  onChanged: onValueChanged,
                  decoration: const InputDecoration(hintText: "Lang 2"),
                ),
              ),
            ],
          ),
        ],
      );

  void onValueChanged(String text) {
    setState(() {
      missingDetails = nameController.text.isEmpty ||
          lang1Controller.text.isEmpty ||
          lang2Controller.text.isEmpty;
    });
  }

  void onCancelPressed() {
    Navigator.pop(context);
  }

  void onCreatePressed() {
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }
    final name = nameController.text;
    final lang1 = lang1Controller.text;
    final lang2 = lang2Controller.text;
    final ownerID = FirebaseAuth.instance.currentUser!.uid;
    final ownerName = FirebaseAuth.instance.currentUser!.displayName;

    FirebaseFirestore.instance
        .collection("folders")
        .doc()
        .set({
          "name": name,
          "lang-1": lang1,
          "lang-2": lang2,
          "owner-id": ownerID,
          "owner-name": ownerName,
          "reverse": false,
          "members": {},
        })
        .then((value) => Navigator.pop(context))
        .onError((error, stackTrace) => print(error));
  }
}
