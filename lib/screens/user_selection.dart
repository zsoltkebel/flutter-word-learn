import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:word_learn/model/friend_model.dart';

typedef OnUserSelected = void Function(Set<UserInfoModel> uids);

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
  List<UserInfoModel> users = [];
  List<UserInfoModel> matches = [];
  Set<UserInfoModel> selected = {};

  @override
  initState() {
    super.initState();
    FirebaseFirestore.instance.collection('users').get().then((snapshot) {
      users = snapshot.docs.map(UserInfoModel.fromSnapshot).toList();
      selected = users
          .where((user) => widget.uids?.contains(user.uid) ?? false)
          .toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
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
          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  setState(() {
                    if (!isSelected(index)) {
                      selected.add(matches[index]);
                    } else {
                      selected.removeWhere(
                          (user) => user.uid == matches[index].uid);
                    }
                    print(selected);
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
                        selected.removeWhere(
                            (user) => user.uid == matches[index].uid);
                      }
                    });
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
          widget.onSelected.call(selected);
        },
        child: Text('Done'),
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
}
