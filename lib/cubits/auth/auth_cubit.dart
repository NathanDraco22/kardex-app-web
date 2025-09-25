import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/core/session_manager.dart';
import 'package:kardex_app_front/src/core/token_manager.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/domain/responses/login_responses.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.authRepository}) : super(AuthInitial());

  final AuthRepository authRepository;

  Future<void> checkSession() async {
    emit(AuthLoading());
    try {
      LoginResponse? loginResponse = await authRepository.getLocalSession();
      if (loginResponse != null) {
        final isTokenNearToExpiration = TokenManager().isTokenNearToExpiration(
          loginResponse.accessToken,
        );
        if (isTokenNearToExpiration) {
          loginResponse = await authRepository.refreshToken(loginResponse.accessToken);
        }

        TokenManager().storeToken(loginResponse.accessToken);
        emit(Authenticated(loginResponse));
        return;
      }
      emit(Unauthenticated());
    } catch (error) {
      if (isClosed) return;
      emit(AuthError(error.toString()));
    }
  }

  Future<void> login(String userId, String password) async {
    emit(AuthLoading());
    try {
      final loginResponse = await authRepository.login(userId, password);
      if (isClosed) return;

      TokenManager().storeToken(loginResponse.accessToken);

      emit(Authenticated(loginResponse));
    } catch (error) {
      if (isClosed) return;
      emit(AuthError(error.toString()));
    }
  }

  Future<void> logout() async {
    TokenManager().removeToken();
    await SessionManager().removeSession();
    emit(Unauthenticated());
  }
}
