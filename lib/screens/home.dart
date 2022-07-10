import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:word_learn/model/user_data.dart';
import 'package:word_learn/screens/collections.dart';
import 'package:word_learn/screens/friends.dart';

class HomeScreen extends StatefulWidget {
  final UserData? userData;

  const HomeScreen({
    Key? key,
    this.userData,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> _screens = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _screens = <Widget>[
      const CollectionsPage(),
      const FriendsPage(),
      Center(
        child: ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            child: const Text('Sign Out')),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: _screens.elementAt(_selectedIndex),
      body: Stack(
        children: [
          Offstage(
            offstage: _selectedIndex != 0,
            child: _screens[0],
          ),
          Offstage(
            offstage: _selectedIndex != 1,
            child: _screens[1],
          ),
          Offstage(
            offstage: _selectedIndex != 2,
            child: _screens[2],
          ),
          Positioned(
            bottom: 0.0,
            child: IgnorePointer(
              child: Container(
                height: 40.0,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).scaffoldBackgroundColor.withOpacity(0),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0.0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_copy_outlined),
            activeIcon: Icon(Icons.folder_copy),
            label: 'Collections',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outlined),
            activeIcon: Icon(Icons.people),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
        currentIndex: _selectedIndex,
        // selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
