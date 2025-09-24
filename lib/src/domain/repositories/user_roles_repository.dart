import 'package:kardex_app_front/src/data/data.dart';
import 'package:kardex_app_front/src/domain/models/user_role/user_role_model.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class UserRolesRepository {
  final UserRolesDataSource userRolesDataSource;

  UserRolesRepository(this.userRolesDataSource);

  Future<UserRoleInDb> createUserRole(CreateUserRole createUserRole) async {
    final result = await userRolesDataSource.createUserRole(createUserRole.toJson());
    return UserRoleInDb.fromJson(result);
  }

  Future<List<UserRoleInDb>> getAllUserRoles() async {
    final results = await userRolesDataSource.getAllUserRoles();
    final response = ListResponse<UserRoleInDb>.fromJson(
      results,
      UserRoleInDb.fromJson,
    );
    return response.data;
  }

  Future<UserRoleInDb?> getUserRoleById(String userRoleId) async {
    final result = await userRolesDataSource.getUserRoleById(userRoleId);
    if (result == null) return null;
    return UserRoleInDb.fromJson(result);
  }

  Future<UserRoleInDb?> updateUserRoleById(
    String userRoleId,
    UpdateUserRole userRole,
  ) async {
    final result = await userRolesDataSource.updateUserRoleById(userRoleId, userRole.toJson());
    if (result == null) return null;
    return UserRoleInDb.fromJson(result);
  }

  Future<UserRoleInDb?> deleteUserRoleById(String userRoleId) async {
    final result = await userRolesDataSource.deleteUserRoleById(userRoleId);
    if (result == null) return null;
    return UserRoleInDb.fromJson(result);
  }
}
