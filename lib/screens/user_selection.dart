import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:word_learn/model/friend_model.dart';

typedef OnUserSelected = void Function(List<UserInfoModel> uids);

class UserSelectionScreen extends StatefulWidget {
  final Set<String>? uids; // uid-s of the initially selected users
  final OnUserSelected onSelected;

  const UserSelectionScreen({
    Key? key,
    required this.onSelected,
    this.uids,
  }) : super(key: key);

  @override
  State<UserSelectionScreen> createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  final textEditingController = TextEditingController();

  List<UserInfoModel> users = [];
  List<UserInfoModel> matches = [];
  List<UserInfoModel> selected = [];

  @override
  initState() {
    super.initState();
    FirebaseFirestore.instance.collection('users').get().then((snapshot) {
      users = snapshot.docs.map(UserInfoModel.fromSnapshot).toList();
      selected = users
          .where((user) => widget.uids?.contains(user.uid) ?? false)
          .toList();
    });
  }

  @override
  dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: textEditingController,
          decoration: const InputDecoration(
            hintText: 'Search',
            border: InputBorder.none,
          ),
          onChanged: _onFilterTextChanged,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          } else {
            users =
                snapshot.data!.docs.map(UserInfoModel.fromSnapshot).toList();
          }
          return _buildBackground();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
          widget.onSelected.call(selected);
        },
        child: const Text('Done'),
      ),
    );
  }

  bool isSelected(index) =>
      selected.map((e) => e.uid).contains(matches[index].uid);

  void _onFilterTextChanged(String text) {
    setState(() {
      if (text.isEmpty) {
        matches = [];
      } else {
        matches = List.from(users.where((user) =>
            user.displayName!.toLowerCase().contains(text.toLowerCase())));
      }
      print(selected);
    });
  }

  Widget _buildBackground() {
    if (textEditingController.text.isEmpty) {
      if (selected.isEmpty) {
        return const Center(
          child: const Text('Search for a user.'),
        );
      } else {
        return ListView.builder(
          itemCount: selected.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                setState(() {
                  selected
                      .removeWhere((user) => user.uid == selected[index].uid);
                });
              },
              leading: Text(selected[index].displayName!),
              trailing: Checkbox(
                value: true,
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      selected.add(selected[index]);
                    } else {
                      selected.removeWhere(
                          (user) => user.uid == selected[index].uid);
                    }
                  });
                },
              ),
            );
          },
        );
      }
    } else if (matches.isEmpty) {
      return const Center(
        child: Text('No user found.'),
      );
    } else {
      return ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              setState(() {
                if (!isSelected(index)) {
                  selected.add(matches[index]);
                } else {
                  selected
                      .removeWhere((user) => user.uid == matches[index].uid);
                }
              });
            },
            leading: Text(matches[index].displayName!),
            trailing: Checkbox(
              value: isSelected(index),
              onChanged: (value) {
                setState(() {
                  if (value!) {
                    selected.add(matches[index]);
                  } else {
                    selected
                        .removeWhere((user) => user.uid == matches[index].uid);
                  }
                });
              },
            ),
          );
        },
      );
    }
  }
}
