import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:word_learn/model/trans_collection.dart';

class CollectionDetailsInputPage extends StatefulWidget {
  final TransCollection? collection;

  const CollectionDetailsInputPage({Key? key, this.collection})
      : super(key: key);

  @override
  State<CollectionDetailsInputPage> createState() =>
      _CollectionDetailsInputPageState();
}

class _CollectionDetailsInputPageState
    extends State<CollectionDetailsInputPage> {
  bool missingDetails = true;

  final nameController = TextEditingController();
  final lang1Controller = TextEditingController();
  final lang2Controller = TextEditingController();
  bool isSwapped = false;

  @override
  void initState() {
    super.initState();
    if (widget.collection != null) {
      nameController.text = widget.collection!.name;
      lang1Controller.text = widget.collection!.language1;
      lang2Controller.text = widget.collection!.language2;
      isSwapped = widget.collection!.reverseFor
          .contains(FirebaseAuth.instance.currentUser!.uid);
      _checkMissingDetail();
    }
  }

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
      appBar: AppBar(
        title: const Text('Collection'),
      ),
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
                    child: const Text('Cancel'),
                    onPressed: onCancelPressed,
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: OutlinedButton(
                    child: Text(widget.collection != null ? 'Done' : 'Create'),
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
            onChanged: (text) => _checkMissingDetail(),
            autofocus: true,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
            decoration: const InputDecoration(
              hintText: 'Name',
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Row(
            children: [
              Expanded(
                child: _buildLanguageTextField(
                  controller: isSwapped ? lang2Controller : lang1Controller,
                  hintText: isSwapped ? 'Lang 2' : 'Lang 1',
                ),
              ),
              const SizedBox(
                width: 10.0,
              ),
              IconButton(
                  onPressed: _onReversePressed,
                  icon: const Icon(Icons.swap_horiz)),
              const SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: _buildLanguageTextField(
                  controller: isSwapped ? lang1Controller : lang2Controller,
                  hintText: isSwapped ? 'Lang 1' : 'Lang 2',
                ),
              ),
            ],
          ),
        ],
      );

  Widget _buildLanguageTextField({
    required TextEditingController controller,
    required String hintText,
  }) =>
      TextField(
        controller: controller,
        onChanged: (text) => _checkMissingDetail(),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            borderSide: BorderSide.none,
          ),
        ),
      );

  void _checkMissingDetail() {
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
        .collection('folders')
        .doc(widget.collection?.id)
        .set({
          'name': name,
          'lang-1': lang1,
          'lang-2': lang2,
          'owner-id': ownerID,
          'owner-name': ownerName,
          'can-view': widget.collection?.visibleFor ??
              [FirebaseAuth.instance.currentUser!.uid],
          'reverse-for': widget.collection?.reverseFor ?? [],
          'members': {},
        })
        .then((value) => Navigator.pop(context, true))
        .onError((error, stackTrace) => print(error));
  }

  void _onReversePressed() {
    //TODO: fix collection check before reversing
    if (widget.collection == null) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    isSwapped = widget.collection!.reverseFor.contains(uid);

    if (isSwapped) {
      // switch back to original
      FirebaseFirestore.instance
          .collection("folders")
          .doc(widget.collection!.id)
          .update({
        "reverse-for": FieldValue.arrayRemove([uid])
      });
      setState(() {
        widget.collection!.reverseFor.remove(uid);
      });
    } else {
      // swap lang-1 and lang-2
      FirebaseFirestore.instance
          .collection("folders")
          .doc(widget.collection!.id)
          .update({
        "reverse-for": FieldValue.arrayUnion([uid])
      });
      setState(() {
        widget.collection!.reverseFor.add(uid);
      });
    }
    setState(() {
      isSwapped = !isSwapped;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Primary language: ${isSwapped ? widget.collection!.language2 : widget.collection!.language1}')));
  }
}
