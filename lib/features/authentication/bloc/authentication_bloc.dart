import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:word_learn/features/authentication/authentication_repository_impl.dart';
import 'package:word_learn/model/user_model.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

// helpful:
// https://petercoding.com/firebase/2022/03/28/using-firebase-with-bloc-pattern-in-flutter/

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository _authenticationRepository;

  AuthenticationBloc(this._authenticationRepository)
      : super(AuthenticationInitial()) {
    on<AuthenticationEvent>((event, emit) async {
      if (event is AuthenticationStarted) {
        UserModel user = await _authenticationRepository.getCurrentUser().first;
        if (user.uid != 'uid') {
          String? displayName =
              await _authenticationRepository.retrieveUserName(user);
          user = UserModel(
              uid: user.uid, email: user.uid, displayName: displayName);
          emit(AuthenticationSuccess(user: user));
        } else {
          emit(AuthenticationFailure());
        }
      } else if (event is AuthenticationSignedOut) {
        await _authenticationRepository.signOut();
        emit(AuthenticationFailure());
      }
    });
  }
}
