import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:word_learn/features/database/database_repository_impl.dart';
import 'package:word_learn/model/trans_collection.dart';
import 'package:word_learn/model/user_model.dart';

part 'database_event.dart';

part 'database_state.dart';

class DatabaseBloc extends Bloc<DatabaseEvent, DatabaseState> {
  final DatabaseRepository _databaseRepository;

  DatabaseBloc(this._databaseRepository) : super(DatabaseInitial()) {
    // on<DatabaseEvent>((event, emit) {
    //   on<DatabaseFetched>(_fetchUserData);
    // });
    on<DatabaseCollectionsFetched>(_fetchCollectionDataForUser);
  }

  _fetchUserData(DatabaseFetched event, Emitter<DatabaseState> emit) async {
    List<UserModel> listOfUserData =
        await _databaseRepository.retrieveUserData();
    emit(DatabaseSuccess(listOfUserData, event.displayName));
  }

  _fetchCollectionDataForUser(
      DatabaseCollectionsFetched event, Emitter<DatabaseState> emit) async {
    List<TransCollection> collections =
        await _databaseRepository.retrieveCollectionsFor(event.user!);
    emit(DatabaseCollectionsSuccess(collections, event.user!.uid));
  }
}