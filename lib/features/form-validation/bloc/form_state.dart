part of 'form_bloc.dart';

abstract class FormState extends Equatable {
  const FormState();
}

class FormInitial extends FormState {
  @override
  List<Object> get props => [];
}

class FormsValidate extends FormState {
  const FormsValidate(
      {required this.email,
      required this.password,
      required this.isEmailValid,
      required this.isPasswordValid,
      required this.isFormValid,
      required this.isLoading,
      this.errorMessage = "",
      required this.isNameValid,
      required this.isFormValidateFailed,
      this.displayName,
      this.isFormSuccessful = false});

  final String email;
  final String? displayName;
  final String password;
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool isFormValid;
  final bool isNameValid;
  final bool isFormValidateFailed;
  final bool isLoading;
  final String errorMessage;
  final bool isFormSuccessful;

  FormsValidate copyWith(
      {String? email,
      String? password,
      String? displayName,
      bool? isEmailValid,
      bool? isPasswordValid,
      bool? isFormValid,
      bool? isLoading,
      String? errorMessage,
      bool? isNameValid,
      bool? isFormValidateFailed,
      bool? isFormSuccessful}) {
    return FormsValidate(
        email: email ?? this.email,
        password: password ?? this.password,
        isEmailValid: isEmailValid ?? this.isEmailValid,
        isPasswordValid: isPasswordValid ?? this.isPasswordValid,
        isFormValid: isFormValid ?? this.isFormValid,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage ?? this.errorMessage,
        isNameValid: isNameValid ?? this.isNameValid,
        displayName: displayName ?? this.displayName,
        isFormValidateFailed: isFormValidateFailed ?? this.isFormValidateFailed,
        isFormSuccessful: isFormSuccessful ?? this.isFormSuccessful);
  }

  @override
  List<Object?> get props => [
        email,
        password,
        isEmailValid,
        isPasswordValid,
        isFormValid,
        isLoading,
        errorMessage,
        isNameValid,
        displayName,
        isFormValidateFailed,
        isFormSuccessful
      ];
}
