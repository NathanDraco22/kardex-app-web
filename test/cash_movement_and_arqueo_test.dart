import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_app_front/src/modules/home/data/home_modules_registry.dart';
import 'package:kardex_app_front/src/tools/printers/cash_movement_printer.dart';
import 'package:kardex_app_front/src/tools/printers/paper_settings.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('cash_movement_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('TotalsResult shiftCashMovements', () {
    test('deserializa shiftCashMovements y mantiene default vacío', () {
      final emptyResult = TotalsResult.fromJson({
        'branchId': 'branch-1',
        'receipts': [],
        'detailReceipts': [],
        'invoices': [],
        'detailInvoices': [],
      });
      expect(emptyResult.shiftCashMovements, isEmpty);

      final withMovements = TotalsResult.fromJson({
        'branchId': 'branch-1',
        'receipts': [],
        'detailReceipts': [],
        'invoices': [],
        'detailInvoices': [],
        'shiftCashMovements': [
          {
            'id': 'mov-1',
            'branchId': 'branch-1',
            'shiftId': 'shift-1',
            'docNumber': 'MOV-001',
            'type': 'out',
            'amount': 2500,
            'reason': 'Garrafón de agua',
            'registerAsExpense': false,
            'createdBy': {'id': 'u-1', 'name': 'Cajero 1'},
            'createdAt': 1700000000000,
          },
        ],
      });

      expect(withMovements.shiftCashMovements, hasLength(1));
      expect(withMovements.shiftCashMovements.first.type, CashMovementType.outMovement);
      expect(withMovements.shiftCashMovements.first.amount, 2500);
      expect(withMovements.shiftCashMovements.first.reason, 'Garrafón de agua');
    });
  });

  group('generateCashMovementTicketPdf', () {
    test('genera bytes PDF válidos en 80mm y 58mm', () async {
      final branch = BranchInDb(
        id: 'b-1',
        name: 'Sucursal Central',
        idCard: 'J0310000000001',
        address: 'Av. Principal',
        email: 'sucursal@example.com',
        phone: '8888-8888',
        createdAt: DateTime(2026, 1, 1),
      );
      final movement = ShiftCashMovementInDb(
        id: 'm-1',
        branchId: 'b-1',
        shiftId: 's-1',
        docNumber: 'MOV-010',
        type: CashMovementType.inMovement,
        amount: 50000,
        reason: 'Fondo adicional de cambio',
        createdBy: const UserInfo(id: 'u-1', name: 'Carlos'),
        createdAt: DateTime(2026, 11, 24, 10, 30),
      );

      final bytes80 = await generateCashMovementTicketPdf(
        movement,
        branch,
        shiftDocNumber: 'T-005',
        paperSize: PaperSize.mm80,
      );
      final bytes58 = await generateCashMovementTicketPdf(
        movement,
        branch,
        shiftDocNumber: 'T-005',
        paperSize: PaperSize.mm58,
      );

      expect(bytes80, isNotEmpty);
      expect(bytes58, isNotEmpty);
    });
  });

  group('Orden de Turnos y Caja en el menú Comercial', () {
    testWidgets('Turnos y Caja aparece en la primera sección junto a Arqueo por Usuario', (
      tester,
    ) async {
      final branch = BranchInDb(
        id: 'b-1',
        name: 'Sucursal Central',
        idCard: 'J0310000000001',
        address: 'Av. Principal',
        email: 'sucursal@example.com',
        phone: '8888-8888',
        isCommerce: true,
        createdAt: DateTime(2026, 1, 1),
      );
      late List<HomeModuleCategory> categories;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              categories = getHomeModuleCategories(context, branch, true);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final commercial = categories.firstWhere(
        (c) => c.id == HomeModuleId.commercial,
      );
      final shiftsIndex = commercial.submodules.indexWhere(
        (s) => s.routeName == RouteNames.shifts,
      );
      final userResultsIndex = commercial.submodules.indexWhere(
        (s) => s.routeName == 'user-operations-results',
      );

      expect(shiftsIndex, isNonNegative);
      expect(userResultsIndex, isNonNegative);
      expect(
        commercial.submodules[shiftsIndex].section,
        'Punto de Venta y Facturación',
      );
      expect(shiftsIndex, lessThan(6));
    });
  });
}
