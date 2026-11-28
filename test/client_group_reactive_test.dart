import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/cubits/client_group_cubit/read_client_group_cubit.dart';
import 'package:kardex_business/kardex_business.dart';

class _FakeClientGroupsRepository with ReactiveRepository<ClientGroupInDb> implements ClientGroupsRepository {
  _FakeClientGroupsRepository(this.groups);

  List<ClientGroupInDb> groups;
  int getAllClientGroupsCalls = 0;

  @override
  Future<List<ClientGroupInDb>> getAllClientGroups() async {
    getAllClientGroupsCalls++;
    return List<ClientGroupInDb>.from(groups);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ClientGroupInDb _buildGroup(String id, String name, {String description = ''}) {
  return ClientGroupInDb(
    id: id,
    name: name,
    description: description,
    createdAt: DateTime(2026),
  );
}

void main() {
  test('carga inicial y agrega grupos creados sin volver a consultar', () async {
    final repository = _FakeClientGroupsRepository([
      _buildGroup('group-1', 'Mayoristas'),
    ]);
    final cubit = ReadClientGroupCubit(repository);
    addTearDown(() async {
      await cubit.close();
      repository.disposeReactiveRepo();
    });

    await cubit.loadAllClientGroups();

    expect(cubit.state, isA<ReadClientGroupSuccess>());
    expect((cubit.state as ReadClientGroupSuccess).clientGroups, hasLength(1));
    expect(repository.getAllClientGroupsCalls, 1);

    repository.notifyItemCreated(_buildGroup('group-2', 'Almacenes'));
    await Future<void>.delayed(Duration.zero);

    final state = cubit.state as ReadClientGroupSuccess;
    expect(state.clientGroups, hasLength(2));
    expect(state.clientGroups.map((group) => group.id), containsAll(['group-1', 'group-2']));
    expect(state.clientGroups.map((group) => group.name), ['Almacenes', 'Mayoristas']);
    expect(repository.getAllClientGroupsCalls, 1);
  });

  test('ensureLoaded no vuelve a consultar cuando ya se cargaron los grupos', () async {
    final repository = _FakeClientGroupsRepository([
      _buildGroup('group-1', 'Mayoristas'),
    ]);
    final cubit = ReadClientGroupCubit(repository);
    addTearDown(() async {
      await cubit.close();
      repository.disposeReactiveRepo();
    });

    await cubit.ensureLoaded();
    await cubit.ensureLoaded();

    expect(cubit.state, isA<ReadClientGroupSuccess>());
    expect(repository.getAllClientGroupsCalls, 1);
  });
}
