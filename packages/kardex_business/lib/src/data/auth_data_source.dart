import 'package:kardex_business/src/local_storage.dart';
import 'package:kardex_business/src/services/http_service.dart';
import 'package:kardex_business/src/tools/http_tool.dart';

class AuthDataSource with HttpService {
  AuthDataSource._(this._sessionStore);
  static AuthDataSource? _instance;
  factory AuthDataSource({required SessionStore sessionStore}) {
    _instance ??= AuthDataSource._(sessionStore);
    return _instance!;
  }

  final _endpoint = "/auths";

  final SessionStore _sessionStore;

  Future<Map<String, dynamic>> login(String userId, String password) async {
    final uri = HttpTools.generateUri("$_endpoint/login");
    final body = {
      'userId': userId,
      'password': password,
    };

    final res = await postQuery(uri, body);

    await _sessionStore.storeSession(res);
    return res;
  }

  Future<Map<String, dynamic>> refreshToken(String token) async {
    final uri = HttpTools.generateUri("$_endpoint/refresh-token");
    final body = {
      'token': token,
    };
    final res = await postQuery(uri, body);

    await _sessionStore.storeSession(res);
    return res;
  }

  Future<void> changePassword(Map<String, dynamic> data) async {
    final uri = HttpTools.generateUri("$_endpoint/change-password");
    final headers = HttpTools.generateAuthHeaders();
    await postQuery(uri, data, headers: headers);
  }

  Future<Map?> getLocalSession() async {
    final session = await _sessionStore.getSession();
    return session;
  }

  Future<Map<String, dynamic>> getUserStatus(String userId) async {
    final uri = HttpTools.generateUri("$_endpoint/user-status/$userId");
    final res = await getQuery(uri);
    return res;
  }
}
