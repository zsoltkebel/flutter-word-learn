import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_learn/features/database/home_view.dart';
import 'package:word_learn/utils/constants.dart';
import 'package:word_learn/features/authentication/bloc/authentication_bloc.dart';
import 'package:word_learn/welcome_view.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const BlocNavigate(),
      title: Constants.title,
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
    );
  }
}

class BlocNavigate extends StatelessWidget {
  const BlocNavigate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state is AuthenticationSuccess) {
          // home
          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                print('waiting');
                return const CircularProgressIndicator.adaptive();
              } else if (snapshot.connectionState ==
                  ConnectionState.active) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return const Text('Error');
                } else if (snapshot.hasData) {
                  //TODO
                  // return const HomeScreen();
                  return const HomeView();
                } else {
                  return const Text('Empty data');
                }
              } else {
                return Text('State: ${snapshot.connectionState}');
              }
            },
          );
        } else {
          return const WelcomeView();
        }
      }
    );
  }
}
