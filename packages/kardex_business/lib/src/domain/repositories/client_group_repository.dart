import 'package:kardex_business/src/data/client_group_data_source.dart';
import 'package:kardex_business/src/domain/models/client_group/client_group_model.dart';
import 'package:kardex_business/src/domain/responses/list_responses.dart';
import 'package:kardex_business/src/tools/reactive_repo/reactive_repository.dart';

class ClientGroupsRepository with ReactiveRepository<ClientGroupInDb> {
  final ClientGroupDataSource clientGroupDataSource;

  ClientGroupsRepository(this.clientGroupDataSource);

  Future<ClientGroupInDb> createClientGroup(
    CreateClientGroup createGroup,
  ) async {
    final result = await clientGroupDataSource.createClientGroup(
      createGroup.toJson(),
    );
    final newGroup = ClientGroupInDb.fromJson(result);
    notifyItemCreated(newGroup);
    return newGroup;
  }

  Future<List<ClientGroupInDb>> getAllClientGroups() async {
    final results = await clientGroupDataSource.getAllClientGroups();

    final response = ListResponse<ClientGroupInDb>.fromJson(
      results,
      ClientGroupInDb.fromJson,
    );

    return response.data;
  }

  Future<ClientGroupInDb?> getClientGroupById(String groupId) async {
    final result = await clientGroupDataSource.getClientGroupById(groupId);
    if (result == null) return null;
    return ClientGroupInDb.fromJson(result);
  }

  Future<ClientGroupInDb?> updateClientGroupById(
    String groupId,
    UpdateClientGroup group,
  ) async {
    final result = await clientGroupDataSource.updateClientGroupById(
      groupId,
      group.toJson(),
    );
    if (result == null) return null;

    final updatedGroup = ClientGroupInDb.fromJson(result);
    notifyItemUpdated(updatedGroup);
    return updatedGroup;
  }

  Future<ClientGroupInDb?> deleteClientGroupById(String groupId) async {
    final result = await clientGroupDataSource.deleteClientGroupById(groupId);
    if (result == null) return null;

    final deletedGroup = ClientGroupInDb.fromJson(result);
    notifyItemDeleted(deletedGroup);
    return deletedGroup;
  }
}
