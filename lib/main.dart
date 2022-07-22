import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_learn/app.dart';
import 'package:word_learn/app_bloc_observer.dart';
import 'package:word_learn/features/authentication/authentication_repository_impl.dart';
import 'package:word_learn/features/authentication/bloc/authentication_bloc.dart';
import 'package:word_learn/features/database/bloc/database_bloc.dart';
import 'package:word_learn/features/database/database_repository_impl.dart';
import 'package:word_learn/features/form-validation/bloc/form_bloc.dart';
import 'package:word_learn/firebase_options.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  BlocOverrides.runZoned(
      () => runApp(MultiBlocProvider(providers: [
            BlocProvider(
              create: (context) =>
                  AuthenticationBloc(AuthenticationRepositoryImpl())
                    ..add(AuthenticationStarted()),
            ),
            BlocProvider(
              create: (context) => FormBloc(
                  AuthenticationRepositoryImpl(), DatabaseRepositoryImpl()),
            ),
            BlocProvider(
              create: (context) => DatabaseBloc(DatabaseRepositoryImpl()),
            )
          ], child: const App())),
      blocObserver: AppBlocObserver());
}
