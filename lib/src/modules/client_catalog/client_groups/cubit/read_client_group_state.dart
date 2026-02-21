part of 'read_client_group_cubit.dart';

sealed class ReadClientGroupState {}

final class ReadClientGroupInitial extends ReadClientGroupState {}

final class ReadClientGroupLoading extends ReadClientGroupState {}

class ReadClientGroupSuccess extends ReadClientGroupState {
  final List<ClientGroupInDb> clientGroups;
  ReadClientGroupSuccess(this.clientGroups);
}

final class ClientGroupReadSearching extends ReadClientGroupSuccess {
  ClientGroupReadSearching(super.clientGroups);
}

class HighlightedClientGroup extends ReadClientGroupSuccess {
  List<ClientGroupInDb> newGroups;
  List<ClientGroupInDb> updatedGroups;
  HighlightedClientGroup(
    super.clientGroups, {
    this.newGroups = const [],
    this.updatedGroups = const [],
  });
}

final class ClientGroupReadError extends ReadClientGroupState {
  final String message;
  ClientGroupReadError(this.message);
}
