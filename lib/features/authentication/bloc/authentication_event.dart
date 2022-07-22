part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();
}

class AuthenticationStarted extends AuthenticationEvent {
  @override
  List<Object?> get props => [];
}

class AuthenticationSignedOut extends AuthenticationEvent {
  @override
  List<Object?> get props => [];
}