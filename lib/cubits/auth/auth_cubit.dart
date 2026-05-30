import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/constants/default_values.dart';
import 'package:kardex_app_front/src/core/session_manager.dart';
import 'package:kardex_app_front/src/core/token_manager.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch.dart';
import 'package:kardex_app_front/src/domain/models/servin/servin.dart';
import 'package:kardex_app_front/src/domain/models/user/user_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/domain/responses/login_responses.dart';
import 'package:kardex_app_front/src/services/exceptions/http_exceptions.dart';
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

  String get currentBranchId => (state is Authenticated) ? (state as Authenticated).branch.id : kOriginBranchId;

  BranchInDb? get currentBranch => (state is Authenticated) ? (state as Authenticated).branch : null;

  List<BranchInDb> get branches => (state is Authenticated) ? (state as Authenticated).branches : [];

  BranchInDb getBranchById(String id) => branches.firstWhere((b) => b.id == id);

  UserInDbWithRole? get user => (state is Authenticated) ? (state as Authenticated).session.user : null;

  Servin? get servin {
    if (state is Authenticated) return (state as Authenticated).servin;
    if (state is Unauthenticated) return (state as Unauthenticated).servin;
    return null;
  }

  String get currentBranchName => currentBranch?.name ?? "No Branch Selected";

  // MARK: - Auth Logic

  Future<void> checkSession() async {
    Servin? currentServin;
    emit(AuthLoading());

    try {
      currentServin = await servinRepository.getCurrentServinFromLocal();

      if (currentServin == null) {
        emit(AuthInactive());
        return;
      }

      _updateNetworkConfig(servin: currentServin);

      final [loginResponseObj, servinObj] = await Future.wait([
        authRepository.getLocalSession(),
        servinRepository.refreshServinStatus(),
      ]);

      LoginResponse? loginResponse = loginResponseObj as LoginResponse?;
      final servin = servinObj as Servin?;

      if (loginResponse != null) {
        final isTokenNearToExpiration = TokenManager().isTokenGotExpired(
          loginResponse.accessToken,
        );
        if (isTokenNearToExpiration) {
          loginResponse = await authRepository.refreshToken(loginResponse.accessToken);
        }

        await _initializeSession(
          loginResponse: loginResponse,
          currentServin: currentServin,
          refreshedServin: servin,
        );
        return;
      }
      emit(Unauthenticated(servin: currentServin));
    } on HttpServiceException catch (error) {
      if (error is UnauthorizedException) {
        if (isClosed) return;
        emit(Unauthenticated(servin: currentServin));
        return;
      }

      if (isClosed) return;
      emit(AuthError(error.toString()));
    } catch (error) {
      if (isClosed) return;
      emit(
        Unauthenticated(
          servin: currentServin,
        ),
      );
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

      _updateNetworkConfig(servin: currentServin);

      // Desestructuración de listas en Dart 3
      final [loginResponseObj, servinObj] = await Future.wait([
        authRepository.login(userId, password),
        servinRepository.refreshServinStatus(),
      ]);
      final loginResponse = loginResponseObj as LoginResponse;
      final servin = servinObj as Servin?;

      if (isClosed) return;

      await _initializeSession(
        loginResponse: loginResponse,
        currentServin: currentServin,
        refreshedServin: servin,
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

      _updateNetworkConfig(
        servin: currentState.servin,
        branch: branch,
      );

      emit(
        Authenticated(
          currentState.session,
          branch,
          currentState.branches,
          currentState.servin,
        ),
      );
    } catch (error) {
      emit(AuthError(error.toString()));
    }
  }

  Future<void> initServinUnauthenticated(Servin servin) async {
    _updateNetworkConfig(servin: servin);
    emit(Unauthenticated(servin: servin));
  }

  Future<void> logout() async {
    Servin? currentServin;
    if (state is Authenticated) {
      currentServin = (state as Authenticated).servin;
    }

    if (currentServin != null) {
      _updateNetworkConfig(servin: currentServin, branch: null);
    } else {
      HttpTools.currentBranch = null;
    }

    TokenManager().removeToken();
    await SessionManager().removeSession();
    emit(Unauthenticated(servin: currentServin));
  }

  Future<void> exitFromBusiness() async {
    await servinRepository.clearCurrentServin();
    emit(AuthInactive());
  }

  // Mark: - Helpers

  void _updateNetworkConfig({
    required Servin servin,
    BranchInDb? branch,
  }) {
    HttpTools.baseUrl = servin.url;
    HttpTools.servin = servin;
    HttpTools.currentBranch = branch;
  }

  Future<void> _initializeSession({
    required LoginResponse loginResponse,
    required Servin currentServin,
    Servin? refreshedServin,
  }) async {
    TokenManager().storeToken(loginResponse.accessToken);
    final initBranchId = loginResponse.user.branches.firstOrNull ?? kOriginBranchId;

    final [branchObj, allBranchesObj] = await Future.wait([
      branchesRepository.getBranchById(initBranchId),
      branchesRepository.getAllBranches(),
    ]);
    final branch = branchObj as BranchInDb?;
    final allBranches = allBranchesObj as List<BranchInDb>;

    if (branch == null) {
      throw Exception("Branch not found");
    }

    try {
      clientGroupRepository.getAllClientGroups();
    } catch (e) {
      log(e.toString());
    }

    _updateNetworkConfig(
      servin: refreshedServin ?? currentServin,
      branch: branch,
    );

    emit(
      Authenticated(
        loginResponse,
        branch,
        allBranches,
        refreshedServin ?? currentServin,
      ),
    );
  }
}
