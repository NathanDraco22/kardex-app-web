import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/modules/commercial/current_devolutions/cubit/read_devolution_cubit.dart';
import 'package:kardex_business/kardex_business.dart';

class _FakeDevolutionsDataSource implements DevolutionsDataSource {
  Map<String, String>? lastParams;
  List<Map<String, dynamic>> nextResults = [];

  @override
  Future<Map<String, dynamic>> getAllDevolutions(Map<String, String> params) async {
    lastParams = params;
    return {'count': nextResults.length, 'data': nextResults};
  }

  @override
  Future<Map<String, dynamic>> createDevolution(Map<String, dynamic> devolution) async {
    return {
      ...devolution,
      'id': 'dev-1',
      'docNumber': 'DEV-001',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  @override
  Future<Map<String, dynamic>?> confirmDevolutionById(String devolutionId) async {
    return _devolutionJson(
      id: devolutionId,
      status: DevolutionStatus.confirmed.name,
      total: 1500,
    );
  }

  @override
  Future<Map<String, dynamic>?> cancelDevolutionById(String devolutionId) async {
    return _devolutionJson(
      id: devolutionId,
      status: DevolutionStatus.cancelled.name,
      total: 1500,
    );
  }

  @override
  Future<Map<String, dynamic>?> deleteDevolutionById(String devolutionId) async {
    return _devolutionJson(
      id: devolutionId,
      status: DevolutionStatus.open.name,
      total: 1500,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Map<String, dynamic> _devolutionJson({
  required String id,
  String branchId = 'branch-1',
  String clientId = 'client-1',
  String clientName = 'Cliente Demo',
  String docNumber = 'DEV-001',
  String status = 'open',
  int total = 1500,
}) {
  return {
    'id': id,
    'branchId': branchId,
    'clientId': clientId,
    'clientInfo': {'name': clientName, 'group': ''},
    'docNumber': docNumber,
    'originalInvoiceId': 'inv-1',
    'originalInvoiceDocNumber': 'FAC-100',
    'returnedItems': const <Map<String, dynamic>>[],
    'description': 'Garantía',
    'status': status,
    'totalCost': 700,
    'total': total,
    'createdAt': DateTime.now().millisecondsSinceEpoch,
    'createdBy': {'id': 'user-1', 'name': 'Usuario Demo'},
  };
}

void main() {
  group('DevolutionsRepository reactivo y ReadDevolutionCubit', () {
    test('inicia en estado Abierta, filtra por sucursal y reacciona sin recargar', () async {
      final ds = _FakeDevolutionsDataSource();
      final repo = DevolutionsRepository(ds);
      final cubit = ReadDevolutionCubit(
        devolutionsRepository: repo,
        branchId: 'branch-1',
      );

      await cubit.loadAllDevolutions();
      expect(ds.lastParams?['branchId'], 'branch-1');
      expect(ds.lastParams?['status'], DevolutionStatus.open.name);

      // Crear devolución en la sucursal activa la inserta arriba y la marca en amarillo
      await repo.createDevolution(
        CreateDevolution(
          branchId: 'branch-1',
          clientId: 'client-1',
          clientInfo: ClientInfo(name: 'Cliente Demo', group: ''),
          originalInvoiceId: 'inv-1',
          originalInvoiceDocNumber: 'FAC-100',
          returnedItems: const [],
          description: 'Garantía',
          totalCost: 700,
          total: 1500,
          createdBy: const UserInfo(id: 'user-1', name: 'Usuario Demo'),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      var state = cubit.state as ReadDevolutionSuccess;
      expect(state.devolutions.map((e) => e.id).toList(), ['dev-1']);
      expect(state.totalAmount, 1500);
      expect(state.newDevolutionIds, contains('dev-1'));
      expect(state.updatedDevolutionIds, isEmpty);

      // Devolución de otra sucursal no debe aparecer
      await repo.createDevolution(
        CreateDevolution(
          branchId: 'branch-other',
          clientId: 'client-1',
          clientInfo: ClientInfo(name: 'Otro Cliente', group: ''),
          originalInvoiceId: 'inv-2',
          originalInvoiceDocNumber: 'FAC-200',
          returnedItems: const [],
          description: 'Otro',
          totalCost: 100,
          total: 200,
          createdBy: const UserInfo(id: 'user-1', name: 'Usuario Demo'),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      state = cubit.state as ReadDevolutionSuccess;
      expect(state.devolutions.length, 1);

      // Con filtro Abierta, al confirmar la devolución se remueve automáticamente de la lista
      await repo.confirmDevolutionById('dev-1');
      await Future<void>.delayed(Duration.zero);
      state = cubit.state as ReadDevolutionSuccess;
      expect(state.devolutions, isEmpty);
      expect(state.totalAmount, 0);

      // Con filtro Todas (clearStatus: true), un update la conserva y la marca en azul
      ds.nextResults = [
        _devolutionJson(id: 'dev-1', status: DevolutionStatus.confirmed.name, total: 1500),
      ];
      await cubit.applyFilters(clearStatus: true);
      expect(ds.lastParams?.containsKey('status'), isFalse);

      await repo.cancelDevolutionById('dev-1');
      await Future<void>.delayed(Duration.zero);
      state = cubit.state as ReadDevolutionSuccess;
      expect(state.devolutions.first.status, DevolutionStatus.cancelled);
      expect(state.updatedDevolutionIds, contains('dev-1'));

      // Eliminar borra de la lista
      await repo.deleteDevolutionById('dev-1');
      await Future<void>.delayed(Duration.zero);
      state = cubit.state as ReadDevolutionSuccess;
      expect(state.devolutions, isEmpty);

      await cubit.close();
      repo.disposeReactiveRepo();
    });

    test('búsqueda local por folio/cliente y clearFilters restablece Abierta', () async {
      final ds = _FakeDevolutionsDataSource()
        ..nextResults = [
          _devolutionJson(id: 'd1', clientName: 'Ferretería Norte', docNumber: 'DEV-101', total: 500),
          _devolutionJson(id: 'd2', clientName: 'Tienda Sur', docNumber: 'DEV-102', total: 800),
        ];
      final repo = DevolutionsRepository(ds);
      final cubit = ReadDevolutionCubit(
        devolutionsRepository: repo,
        branchId: 'branch-1',
      );

      await cubit.loadAllDevolutions();
      cubit.searchDevolution('norte');

      var state = cubit.state as ReadDevolutionSuccess;
      expect(state.devolutions.map((e) => e.id).toList(), ['d1']);
      expect(state.totalAmount, 500);

      cubit.searchDevolution('DEV-102');
      state = cubit.state as ReadDevolutionSuccess;
      expect(state.devolutions.map((e) => e.id).toList(), ['d2']);
      expect(state.totalAmount, 800);

      await cubit.applyFilters(clearStatus: true, clientId: 'client-9');
      expect(cubit.status, isNull);
      expect(cubit.clientId, 'client-9');

      await cubit.clearFilters();
      expect(cubit.status, DevolutionStatus.open);
      expect(cubit.clientId, isNull);
      expect(cubit.searchKeyword, isEmpty);

      await cubit.close();
      repo.disposeReactiveRepo();
    });
  });
}
