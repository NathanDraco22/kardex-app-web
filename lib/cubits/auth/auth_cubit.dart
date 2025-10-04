import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/core/session_manager.dart';
import 'package:kardex_app_front/src/core/token_manager.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/domain/responses/login_responses.dart';
import 'package:kardex_app_front/src/services/exceptions/http_exceptions.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.authRepository,
    required this.branchesRepository,
  }) : super(AuthInitial());

  final AuthRepository authRepository;
  final BranchesRepository branchesRepository;

  Future<void> checkSession() async {
    emit(AuthLoading());
    try {
      LoginResponse? loginResponse = await authRepository.getLocalSession();
      if (loginResponse != null) {
        final isTokenNearToExpiration = TokenManager().isTokenGotExpired(
          loginResponse.accessToken,
        );
        if (isTokenNearToExpiration) {
          loginResponse = await authRepository.refreshToken(loginResponse.accessToken);
        }

        TokenManager().storeToken(loginResponse.accessToken);

        final branch = await branchesRepository.getBranchById(BranchesTool.getCurrentBranchId());

        if (branch == null) {
          throw Exception("Branch not found");
        }
        emit(Authenticated(loginResponse, branch));
        return;
      }
      emit(Unauthenticated());
    } on HttpServiceException catch (error) {
      if (error is UnauthorizedException) {
        if (isClosed) return;
        emit(Unauthenticated());
      }

      if (isClosed) return;
      emit(AuthError(error.toString()));
    } catch (error) {
      if (isClosed) return;
      emit(Unauthenticated());
    }
  }

  Future<void> login(String userId, String password) async {
    emit(AuthLoading());
    try {
      final loginResponse = await authRepository.login(userId, password);

      if (isClosed) return;

      TokenManager().storeToken(loginResponse.accessToken);

      final branch = await branchesRepository.getBranchById(BranchesTool.getCurrentBranchId());

      if (branch == null) {
        throw Exception("Branch not found");
      }

      emit(Authenticated(loginResponse, branch));
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
