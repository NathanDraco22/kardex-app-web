import 'package:kardex_app_front/src/data/auth_data_source.dart';
import 'package:kardex_app_front/src/data/servin_status_data_source.dart';
import 'package:kardex_app_front/src/domain/models/common/change_password.dart';
import 'package:kardex_app_front/src/domain/responses/login_responses.dart';
import 'package:kardex_app_front/src/domain/responses/servin_status_response.dart';

class AuthRepository {
  final AuthDataSource authDataSource;
  final ServinStatusDataSource servinStatusDataSource;

  AuthRepository(this.authDataSource, this.servinStatusDataSource);

  Future<LoginResponse> login(String userId, String password) async {
    final result = await authDataSource.login(userId, password);
    return LoginResponse.fromJson(result);
  }

  Future<LoginResponse> refreshToken(String token) async {
    final result = await authDataSource.refreshToken(token);
    return LoginResponse.fromJson(result);
  }

  Future<void> changePassword(ChangePasswordBody data) async {
    await authDataSource.changePassword(data.toJson());
  }

  Future<LoginResponse?> getLocalSession() async {
    final result = await authDataSource.getLocalSession();
    if (result == null) return null;
    return LoginResponse.fromJson(result);
  }

  Future<ServinStatusResponse> getServinStatus() async {
    final result = await servinStatusDataSource.getServinStatus();
    return ServinStatusResponse.fromJson(result);
  }
}
