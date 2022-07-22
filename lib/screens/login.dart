import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final nameController = TextEditingController();
  final emailController = TextEditingController(text: 'kevel.zsolt@gmail.com');
  final passwordController = TextEditingController(text: '123456789');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TextField(
              controller: nameController,
            ),
            TextField(
              controller: emailController,
            ),
            TextField(
              controller: passwordController,
            ),
            ElevatedButton(
                onPressed: () =>
                    register(emailController.text, passwordController.text),
                child: Text('Sign Up')),
            ElevatedButton(
                onPressed: () =>
                    signIn(emailController.text, passwordController.text),
                child: Text('Sign In')),
          ],
        ),
      ),
    );
  }

  void register(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('name ${FirebaseAuth.instance.currentUser?.displayName}');
      await userCredential.user?.updateDisplayName(nameController.text);

      FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'uid': 'hmmm',
        'display-name': nameController.text,
        'photo-url': null,
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  void signIn(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('name ${FirebaseAuth.instance.currentUser?.displayName}');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }
}
