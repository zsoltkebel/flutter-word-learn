part of 'database_bloc.dart';

abstract class DatabaseState extends Equatable {
  const DatabaseState();
}

class DatabaseInitial extends DatabaseState {
  @override
  List<Object> get props => [];
}

class DatabaseSuccess extends DatabaseState {
  final List<UserModel> listOfUserData;
  final String? displayName;

  const DatabaseSuccess(this.listOfUserData, this.displayName);

  @override
  List<Object?> get props => [listOfUserData, displayName];
}

class DatabaseCollectionsSuccess extends DatabaseState {
  final List<TransCollection> collections;
  final String? uid;

  const DatabaseCollectionsSuccess(this.collections, this.uid);

  @override
  List<Object?> get props => [collections, uid];
}

class DatabaseError extends DatabaseState {
  @override
  List<Object?> get props => [];
}
