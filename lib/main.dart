import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:word_learn/screens/home.dart';
import 'package:word_learn/screens/login.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: AppBarTheme.of(context).copyWith(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        primarySwatch: Colors.cyan,
      ),
      home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              print('progress');
              return const CircularProgressIndicator.adaptive();
            }
            User? user = snapshot.data;
            print(user);
            if (user == null) {
              return Login();
            } else {
              print('logged in: ${user.uid}');
              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    print('waiting');
                    return const CircularProgressIndicator.adaptive();
                  } else if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return const Text('Error');
                    } else if (snapshot.hasData) {
                      return const HomeScreen();
                    } else {
                      return const Text('Empty data');
                    }
                  } else {
                    return Text('State: ${snapshot.connectionState}');
                  }
                },
              );
            }
          }),
    );
  }
}