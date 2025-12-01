import 'package:kardex_app_front/src/data/data.dart';
import 'package:kardex_app_front/src/domain/models/user/user_model.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class UsersRepository {
  final UsersDataSource usersDataSource;

  UsersRepository(this.usersDataSource);

  Future<UserInDb> createUser(CreateUser createUser) async {
    final result = await usersDataSource.createUser(createUser.toJson());
    return UserInDb.fromJson(result);
  }

  Future<List<UserInDbWithRole>> getPaginatedUsers(int offset) async {
    final results = await usersDataSource.getPaginatedUsers(offset: offset);
    final response = ListResponse<UserInDbWithRole>.fromJson(
      results,
      UserInDbWithRole.fromJson,
    );
    return response.data;
  }

  Future<List<UserInDbWithRole>> getAllActiveUsers({String? branchId}) async {
    final results = await usersDataSource.getAllActiveUsers(branchId: branchId);
    final response = ListResponse<UserInDbWithRole>.fromJson(
      results,
      UserInDbWithRole.fromJson,
    );
    return response.data;
  }

  Future<UserInDb?> getUserById(String userId) async {
    final result = await usersDataSource.getUserById(userId);
    if (result == null) return null;
    return UserInDb.fromJson(result);
  }

  Future<List<UserInDb>> searchUserByKeyword(String keyword) async {
    final result = await usersDataSource.searchUserByKeyword(keyword);
    final response = ListResponse<UserInDb>.fromJson(
      result,
      UserInDb.fromJson,
    );
    return response.data;
  }

  Future<UserInDb?> updateUserById(
    String userId,
    UpdateUser user,
  ) async {
    final result = await usersDataSource.updateUserById(userId, user.toJson());
    if (result == null) return null;
    return UserInDb.fromJson(result);
  }

  Future<UserInDb?> deleteUserById(String userId) async {
    final result = await usersDataSource.deleteUserById(userId);
    if (result == null) return null;
    return UserInDb.fromJson(result);
  }
}
