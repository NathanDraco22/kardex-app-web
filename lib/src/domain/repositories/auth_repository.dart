import 'package:kardex_app_front/src/data/auth_data_source.dart';
import 'package:kardex_app_front/src/domain/responses/login_responses.dart';

class AuthRepository {
  final AuthDataSource authDataSource;

  AuthRepository(this.authDataSource);

  Future<LoginResponse> login(String userId, String password) async {
    final result = await authDataSource.login(userId, password);
    return LoginResponse.fromJson(result);
  }

  Future<LoginResponse> refreshToken(String token) async {
    final result = await authDataSource.refreshToken(token);
    return LoginResponse.fromJson(result);
  }

  Future<LoginResponse?> getLocalSession() async {
    final result = await authDataSource.getLocalSession();
    if (result == null) return null;
    return LoginResponse.fromJson(result);
  }
}
