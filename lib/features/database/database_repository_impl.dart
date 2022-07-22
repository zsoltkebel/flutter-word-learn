import 'package:word_learn/features/database/database_service.dart';
import 'package:word_learn/model/user_model.dart';

abstract class DatabaseRepository {
  Future<void> saveUserData(UserModel user);

  Future<List<UserModel>> retrieveUserData();
}

class DatabaseRepositoryImpl implements DatabaseRepository {
  DatabaseService service = DatabaseService();

  @override
  Future<void> saveUserData(UserModel user) {
    return service.addUserData(user);
  }

  @override
  Future<List<UserModel>> retrieveUserData() {
    return service.retrieveUserData();
  }
}
