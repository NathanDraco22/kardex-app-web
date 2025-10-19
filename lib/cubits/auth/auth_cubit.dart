import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/core/session_manager.dart';
import 'package:kardex_app_front/src/core/token_manager.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch.dart';
import 'package:kardex_app_front/src/domain/models/servin/servin.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/domain/responses/login_responses.dart';
import 'package:kardex_app_front/src/services/exceptions/http_exceptions.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.authRepository,
    required this.branchesRepository,
    required this.servinRepository,
  }) : super(AuthInitial());

  final AuthRepository authRepository;
  final BranchesRepository branchesRepository;
  final ServinRepository servinRepository;

  Future<void> checkSession() async {
    emit(AuthLoading());
    try {
      final currentServin = await servinRepository.getCurrentServinFromLocal();

      if (currentServin == null) {
        emit(AuthInactive());
        return;
      }
      HttpTools.baseUrl = currentServin.url;

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
        HttpTools.baseUrl = currentServin.url;
        emit(Authenticated(loginResponse, branch, currentServin));
        return;
      }
      emit(Unauthenticated(servin: currentServin));
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
      final currentServin = await servinRepository.getCurrentServinFromLocal();

      if (currentServin == null) {
        emit(AuthInactive());
        return;
      }

      HttpTools.baseUrl = currentServin.url;

      final loginResponse = await authRepository.login(userId, password);

      if (isClosed) return;

      TokenManager().storeToken(loginResponse.accessToken);

      final branch = await branchesRepository.getBranchById(BranchesTool.getCurrentBranchId());

      if (branch == null) {
        throw Exception("Branch not found");
      }

      HttpTools.baseUrl = currentServin.url;
      emit(Authenticated(loginResponse, branch, currentServin));
    } catch (error) {
      if (isClosed) return;
      emit(AuthError(error.toString()));
    }
  }

  Future<void> logout() async {
    Servin? currentServin;
    if (state is Authenticated) {
      currentServin = (state as Authenticated).servin;
    }
    TokenManager().removeToken();
    await SessionManager().removeSession();
    emit(Unauthenticated(servin: currentServin));
  }

  Future<void> exitFromBusiness() async {
    await servinRepository.clearCurrentServin();
    emit(AuthInactive());
  }
}
