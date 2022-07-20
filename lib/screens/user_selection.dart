import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:word_learn/model/custom_user_info.dart';

typedef OnUserSelected = void Function(List<CustomUserInfo> uids);

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

  List<CustomUserInfo> users = [];
  List<CustomUserInfo> matches = [];
  List<CustomUserInfo>? selected;

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
            hintText: 'Search for people',
            border: InputBorder.none,
          ),
          onChanged: _onFilterTextChanged,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            users =
                snapshot.data!.docs.map(CustomUserInfo.fromSnapshot).toList();
            selected ??= users
                .where((user) => widget.uids?.contains(user.uid) ?? false)
                .toList();
          } else {
            //TODO: be more specific about what is happening to the user
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          return _buildBackground();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context);
          widget.onSelected.call(selected ?? []);
        },
        icon: const Icon(Icons.done),
        label: const Text('Done'),
      ),
    );
  }

  bool isSelected(index) =>
      selected?.map((e) => e.uid).contains(matches[index].uid) ?? false;

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
      if (selected != null && selected!.length > 1) {
        return _buildSharedWithList();
      }
      return const Center(
        child: Text('Search for a user.'),
      );
    } else {
      if (matches.isEmpty) {
        return _buildNoResultMessage();
      }
      return _buildMatchesList();
    }
  }

  Widget _buildNoResultMessage() => Center(
        child: Text(
          'No user found',
          style: Theme.of(context).textTheme.labelLarge,
        ),
      );

  Widget _buildSharedWithList() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Can collaborate:",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: selected?.length,
              itemBuilder: (context, index) {
                return _buildUserListTile(selected![index]);
              },
            ),
          ),
        ],
      );

  Widget _buildMatchesList() => ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) {
          if (matches[index].uid == FirebaseAuth.instance.currentUser?.uid) {
            return Container(); // Do not show current user among results
          }
          return _buildUserListTile(matches[index]);
        },
      );

  Widget _buildUserListTile(CustomUserInfo usr) {
    if (usr.uid == FirebaseAuth.instance.currentUser?.uid) {
      return Container(); // Do not show current user among results
    }
    bool isSelected = selected?.any((u) => u.uid == usr.uid) ?? false;
    return ListTile(
      onTap: () {
        setState(() {
          if (isSelected) {
            selected?.removeWhere((u) => u.uid == usr.uid);
          } else {
            selected?.add(usr);
          }
        });
      },
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        child: Text(usr.displayName?.substring(0, 1).toUpperCase() ?? ""),
      ),
      title: Text(usr.displayName!),
      trailing: Checkbox(
        value: isSelected,
        onChanged: (value) {
          setState(() {
            if (value!) {
              selected?.add(usr);
            } else {
              selected?.removeWhere((user) => user.uid == usr.uid);
            }
          });
        },
      ),
    );
  }
}
