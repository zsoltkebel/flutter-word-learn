part of 'database_bloc.dart';

abstract class DatabaseEvent extends Equatable {
  const DatabaseEvent();
}

class DatabaseFetched extends DatabaseEvent {
  final String? displayName;

  const DatabaseFetched(this.displayName);

  @override
  List<Object?> get props => [displayName];
}

class DatabaseCollectionsFetched extends DatabaseEvent {
  final UserModel? user;

  const DatabaseCollectionsFetched(this.user);

  @override
  List<Object?> get props => [user];
}
