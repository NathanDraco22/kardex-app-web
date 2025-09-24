import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/constant.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class UsersDataSource with HttpService {
  UsersDataSource._();
  static final UsersDataSource instance = UsersDataSource._();
  factory UsersDataSource() {
    return instance;
  }

  final _endpoint = "/users";

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> user) async {
    final uri = HttpTools.generateUri(_endpoint);
    final res = await postQuery(uri, user);
    return res;
  }

  Future<Map<String, dynamic>> getPaginatedUsers({required int offset}) async {
    final uri = HttpTools.generateUri(
      _endpoint,
      queryParameters: {
        "offset": offset.toString(),
        "limit": paginationItems.toString(),
      },
    );
    final res = await getQuery(uri);
    return res;
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final uri = HttpTools.generateUri("$_endpoint/$userId");
    final res = await getQuery(uri);
    return res;
  }

  Future<Map<String, dynamic>> searchUserByKeyword(String keyword) async {
    final uri = HttpTools.generateUri("$_endpoint/search/$keyword");
    final res = await getQuery(uri);
    return res;
  }

  Future<Map<String, dynamic>?> updateUserById(
    String userId,
    Map<String, dynamic> user,
  ) async {
    final uri = HttpTools.generateUri("$_endpoint/$userId");
    final res = await patchQuery(uri, body: user);
    return res;
  }

  Future<Map<String, dynamic>?> deleteUserById(String userId) async {
    final uri = HttpTools.generateUri("$_endpoint/$userId");
    final res = await deleteQuery(uri);
    return res;
  }
}
