import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'roles_state.dart';

class RolesCubit extends Cubit<RolesState> {
  RolesCubit({required this.userRolesRepository}) : super(RolesInitial());

  final UserRolesRepository userRolesRepository;

  Future<void> loadRolesAndModules() async {
    emit(RolesLoading());
    try {
      final results = await Future.wait([
        userRolesRepository.getAllUserRoles(),
        userRolesRepository.getAvailableModules(),
      ]);

      final roles = results[0] as List<UserRoleInDb>;
      final catalog = results[1] as ModulesCatalog;

      if (isClosed) return;
      emit(RolesLoaded(roles: roles, catalog: catalog));
    } catch (e) {
      if (isClosed) return;
      emit(RolesError(e.toString()));
    }
  }

  Future<bool> createRole({
    required String name,
    required List<String> access,
  }) async {
    final current = state;
    if (current is! RolesLoaded) return false;

    emit(current.copyWith(isSubmitting: true));
    try {
      final created = await userRolesRepository.createUserRole(
        CreateUserRole(name: name.trim(), access: access),
      );
      if (isClosed) return false;

      emit(
        current.copyWith(
          roles: [created, ...current.roles],
          isSubmitting: false,
          actionSuccess: 'Rol "${created.name}" creado correctamente',
        ),
      );
      return true;
    } catch (e) {
      if (isClosed) return false;
      emit(current.copyWith(isSubmitting: false, actionError: e.toString()));
      return false;
    }
  }

  Future<bool> updateRole({
    required String roleId,
    required String name,
    required List<String> access,
  }) async {
    final current = state;
    if (current is! RolesLoaded) return false;

    emit(current.copyWith(isSubmitting: true));
    try {
      final updated = await userRolesRepository.updateUserRoleById(
        roleId,
        UpdateUserRole(name: name.trim(), access: access),
      );
      if (isClosed) return false;

      if (updated == null) {
        emit(
          current.copyWith(
            isSubmitting: false,
            actionError: 'No se encontró el rol a actualizar',
          ),
        );
        return false;
      }

      final updatedList = current.roles
          .map((r) => r.id == roleId ? updated : r)
          .toList();

      emit(
        current.copyWith(
          roles: updatedList,
          isSubmitting: false,
          actionSuccess: 'Rol "${updated.name}" actualizado',
        ),
      );
      return true;
    } catch (e) {
      if (isClosed) return false;
      emit(current.copyWith(isSubmitting: false, actionError: e.toString()));
      return false;
    }
  }

  Future<bool> deleteRole(UserRoleInDb role) async {
    final current = state;
    if (current is! RolesLoaded) return false;

    emit(current.copyWith(isSubmitting: true));
    try {
      await userRolesRepository.deleteUserRoleById(role.id);
      if (isClosed) return false;

      final remaining = current.roles.where((r) => r.id != role.id).toList();
      emit(
        current.copyWith(
          roles: remaining,
          isSubmitting: false,
          actionSuccess: 'Rol "${role.name}" eliminado',
        ),
      );
      return true;
    } catch (e) {
      if (isClosed) return false;
      emit(current.copyWith(isSubmitting: false, actionError: e.toString()));
      return false;
    }
  }
}
