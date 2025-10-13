import 'package:kardex_app_front/src/core/session_manager.dart';
import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class AuthDataSource with HttpService {
  AuthDataSource._();
  static final AuthDataSource instance = AuthDataSource._();
  factory AuthDataSource() {
    return instance;
  }

  final _endpoint = "/auths";

  final _sessionManager = SessionManager();

  Future<Map<String, dynamic>> login(String userId, String password) async {
    final uri = HttpTools.generateUri("$_endpoint/login");
    final body = {
      'userId': userId,
      'password': password,
    };

    final res = await postQuery(uri, body);

    await _sessionManager.storeSession(res);
    return res;
  }

  Future<Map<String, dynamic>> refreshToken(String token) async {
    final uri = HttpTools.generateUri("$_endpoint/refresh-token");
    final body = {
      'token': token,
    };
    final res = await postQuery(uri, body);

    await _sessionManager.storeSession(res);
    return res;
  }

  Future<void> changePassword(Map<String, dynamic> data) async {
    final uri = HttpTools.generateUri("$_endpoint/change-password");
    final headers = HttpTools.generateAuthHeaders();
    await postQuery(uri, data, headers: headers);
  }

  Future<Map?> getLocalSession() async {
    final session = await _sessionManager.getSession();
    return session;
  }
}
