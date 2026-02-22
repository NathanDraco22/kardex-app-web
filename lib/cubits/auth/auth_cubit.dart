import 'dart:developer';

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
    required this.clientGroupRepository,
  }) : super(AuthInitial());

  final AuthRepository authRepository;
  final BranchesRepository branchesRepository;
  final ServinRepository servinRepository;
  final ClientGroupsRepository clientGroupRepository;

  Future<void> checkSession() async {
    emit(AuthLoading());
    try {
      final currentServin = await servinRepository.getCurrentServinFromLocal();

      if (currentServin == null) {
        emit(AuthInactive());
        return;
      }
      HttpTools.baseUrl = currentServin.url;

      final result = await Future.wait([
        authRepository.getLocalSession(),
        servinRepository.refreshServinStatus(),
      ]);
      LoginResponse? loginResponse = result[0] as LoginResponse?;
      final servin = result[1] as Servin?;

      if (loginResponse != null) {
        final isTokenNearToExpiration = TokenManager().isTokenGotExpired(
          loginResponse.accessToken,
        );
        if (isTokenNearToExpiration) {
          loginResponse = await authRepository.refreshToken(loginResponse.accessToken);
        }

        TokenManager().storeToken(loginResponse.accessToken);
        final initBranchId = loginResponse.user.branches.firstOrNull ?? BranchesTool.getCurrentBranchId();

        final results = await Future.wait([
          branchesRepository.getBranchById(initBranchId),
          branchesRepository.getAllBranches(),
        ]);
        final branch = results[0] as BranchInDb?;

        if (branch == null) {
          throw Exception("Branch not found");
        }
        HttpTools.baseUrl = currentServin.url;
        BranchesTool.setCurrentBranch(branch);
        BranchesTool.setBranches(results[1] as List<BranchInDb>);

        try {
          clientGroupRepository.getAllClientGroups();
        } catch (e) {
          log(e.toString());
        }

        emit(
          Authenticated(
            loginResponse,
            branch,
            servin ?? currentServin,
          ),
        );
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

      final result = await Future.wait([
        authRepository.login(userId, password),
        servinRepository.refreshServinStatus(),
      ]);
      final loginResponse = result[0] as LoginResponse;
      final servin = result[1] as Servin?;

      if (isClosed) return;

      TokenManager().storeToken(loginResponse.accessToken);

      final initBranchId = loginResponse.user.branches.firstOrNull ?? BranchesTool.getCurrentBranchId();

      final results = await Future.wait([
        branchesRepository.getBranchById(initBranchId),
        branchesRepository.getAllBranches(),
      ]);
      final branch = results[0] as BranchInDb?;

      if (branch == null) {
        throw Exception("Branch not found");
      }

      HttpTools.baseUrl = currentServin.url;
      BranchesTool.setCurrentBranch(branch);
      BranchesTool.setBranches(results[1] as List<BranchInDb>);

      try {
        clientGroupRepository.getAllClientGroups();
      } catch (e) {
        log(e.toString());
      }
      emit(
        Authenticated(
          loginResponse,
          branch,
          servin ?? currentServin,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(AuthError(error.toString()));
    }
  }

  Future<void> changeBranch(String branchId) async {
    final currentState = state;
    if (currentState is! Authenticated) return;
    emit(AuthLoading());
    try {
      final branch = await branchesRepository.getBranchById(branchId);

      if (branch == null) {
        throw Exception("Branch not found");
      }

      BranchesTool.setCurrentBranch(branch);
      emit(
        Authenticated(
          currentState.session,
          branch,
          currentState.servin,
        ),
      );
    } catch (error) {
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
