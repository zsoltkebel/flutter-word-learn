import 'package:firebase_auth/firebase_auth.dart';
import 'package:word_learn/model/user_model.dart';

class AuthenticationService {
  FirebaseAuth auth = FirebaseAuth.instance;

  Stream<UserModel> retrieveCurrentUser() {
    return auth.authStateChanges().map((User? user) {
      if (user != null) {
        return UserModel(uid: user.uid, email: user.email);
      } else {
        return UserModel(uid: 'uid'); // means user is not signed in
      }
    });
  }

  Future<UserCredential?> signUp(UserModel user) async {
    try {
      UserCredential userCredential = await auth
          .createUserWithEmailAndPassword(
          email: user.email!, password: user.password!);
      //TODO: below for email verification
      // verifyEmail();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  Future<UserCredential?> signIn(UserModel user) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: user.email!, password: user.password!);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  Future<void> verifyEmail() async {
    User? user = auth.currentUser;
    if (user != null && !user.emailVerified) {
      return await user.sendEmailVerification();
    }
  }

  Future<void> signOut() async {
    return await auth.signOut();
  }
}