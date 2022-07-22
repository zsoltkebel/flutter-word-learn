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
          //TODO: change below to HomeView for example view
          return const HomeView();
        } else {
          return const WelcomeView();
        }
      }
    );
  }
}
