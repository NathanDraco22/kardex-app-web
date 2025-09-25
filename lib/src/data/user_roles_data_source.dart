import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class UserRolesDataSource with HttpService {
  UserRolesDataSource._();
  static final UserRolesDataSource instance = UserRolesDataSource._();
  factory UserRolesDataSource() {
    return instance;
  }

  final _endpoint = "/user-roles";

  Future<Map<String, dynamic>> createUserRole(Map<String, dynamic> userRole) async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(uri, userRole, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getAllUserRoles() async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> getUserRoleById(String userRoleId) async {
    final uri = HttpTools.generateUri("$_endpoint/$userRoleId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> updateUserRoleById(
    String userRoleId,
    Map<String, dynamic> userRole,
  ) async {
    final uri = HttpTools.generateUri("$_endpoint/$userRoleId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await patchQuery(uri, body: userRole, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> deleteUserRoleById(String userRoleId) async {
    final uri = HttpTools.generateUri("$_endpoint/$userRoleId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await deleteQuery(uri, headers: headers);
    return res;
  }
}
