part of 'roles_cubit.dart';

sealed class RolesState {}

final class RolesInitial extends RolesState {}

final class RolesLoading extends RolesState {}

final class RolesLoaded extends RolesState {
  final List<UserRoleInDb> roles;
  final ModulesCatalog catalog;
  final bool isSubmitting;
  final String? actionError;
  final String? actionSuccess;

  RolesLoaded({
    required this.roles,
    required this.catalog,
    this.isSubmitting = false,
    this.actionError,
    this.actionSuccess,
  });

  RolesLoaded copyWith({
    List<UserRoleInDb>? roles,
    ModulesCatalog? catalog,
    bool? isSubmitting,
    String? actionError,
    String? actionSuccess,
  }) {
    return RolesLoaded(
      roles: roles ?? this.roles,
      catalog: catalog ?? this.catalog,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionError: actionError,
      actionSuccess: actionSuccess,
    );
  }
}

final class RolesError extends RolesState {
  final String message;

  RolesError(this.message);
}
