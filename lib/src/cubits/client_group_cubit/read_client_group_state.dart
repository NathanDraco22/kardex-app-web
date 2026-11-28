part of 'read_client_group_cubit.dart';

sealed class ReadClientGroupState {}

final class ReadClientGroupInitial extends ReadClientGroupState {}

final class ReadClientGroupLoading extends ReadClientGroupState {}

class ReadClientGroupSuccess extends ReadClientGroupState {
  final List<ClientGroupInDb> clientGroups;
  ReadClientGroupSuccess(this.clientGroups);
}

final class ClientGroupReadError extends ReadClientGroupState {
  final String message;
  ClientGroupReadError(this.message);
}
