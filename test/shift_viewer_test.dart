import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/adaptive_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/shift_viewer.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  BranchInDb buildBranch() => BranchInDb(
        id: 'b-1',
        name: 'Sucursal Central',
        idCard: 'J0310000000001',
        address: 'Av. Principal #10',
        email: 'sucursal@example.com',
        phone: '8888-8888',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

  ShiftInDb buildClosedShift() => ShiftInDb(
        id: 'shift-1',
        branchId: 'b-1',
        branchName: 'Sucursal Central',
        docNumber: 'T-001',
        status: ShiftStatus.closed,
        initialCash: 100000,
        openingNotes: 'Fondo inicial completo',
        openedBy: const UserInfo(id: 'u-1', name: 'Cajero Uno'),
        openedAt: DateTime(2026, 11, 24, 8, 0).millisecondsSinceEpoch,
        closedBy: const UserInfo(id: 'u-1', name: 'Cajero Uno'),
        closedAt: DateTime(2026, 11, 24, 17, 30).millisecondsSinceEpoch,
        closingNotes: 'Todo cuadrado sin novedad',
        invoiceCashTotal: 250000,
        invoiceCount: 5,
        receiptCashTotal: 50000,
        receiptCount: 1,
        cashInTotal: 10000,
        devolutionTotal: 5000,
        devolutionCount: 1,
        cashOutTotal: 15000,
        expectedCash: 390000,
        countedCash: 390000,
        cashDifference: 0,
        totalTransfers: 80000,
        totalCardsAndOthers: 40000,
        invoiceCreditTotal: 30000,
        creditNoteTotal: 2000,
        creditNoteCount: 1,
        grandTotal: 450000,
        createdAt: DateTime(2026, 11, 24, 8, 0),
        updatedAt: DateTime(2026, 11, 24, 17, 30),
      );

  testWidgets(
    'ShiftViewer muestra título, las 3 acciones (PDF, Compartir, Imprimir) y resumen completo',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final branch = buildBranch();
      final shift = buildClosedShift();

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1280, 800)),
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    showAdaptiveViewer(
                      context: context,
                      builder: (_) => ShiftViewer(
                        shift: shift,
                        branch: branch,
                      ),
                    );
                  },
                  child: const Text('Abrir Visor'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir Visor'));
      await tester.pumpAndSettle();

      expect(find.text('Turno #T-001'), findsOneWidget);
      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
      expect(find.byIcon(Icons.print), findsOneWidget);

      expect(find.text('Corte de Turno'), findsOneWidget);
      expect(find.text('No. T-001'), findsOneWidget);
      expect(find.text('Sucursal Central'), findsOneWidget);
      expect(find.text('Efectivo esperado'), findsOneWidget);
      expect(find.text('Efectivo contado'), findsOneWidget);
      expect(find.text('Diferencia'), findsOneWidget);
      expect(find.text('TOTAL GENERAL'), findsOneWidget);
      expect(
        find.text('Observaciones de cierre: Todo cuadrado sin novedad'),
        findsOneWidget,
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Turno #T-001'), findsNothing);
    },
  );
}
