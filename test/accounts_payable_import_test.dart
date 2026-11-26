import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/modules/imports/dialogs/import_preview_dialog.dart';
import 'package:kardex_app_front/src/modules/imports/tools/import_templates.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('ImportTemplates genera plantilla CSV de cuentas por pagar', () {
    final template = ImportTemplates.forType(ImportType.accountsPayable);

    expect(template.fileName, 'plantilla_cuentas_por_pagar.csv');
    expect(
      template.columns,
      [
        'supplierName',
        'docNumber',
        'date',
        'expirationDate',
        'amount',
        'amountPaid',
        'description',
      ],
    );
    expect(
      template.content,
      'supplierName,docNumber,date,expirationDate,amount,amountPaid,description\n',
    );
  });

  test('ImportPreviewResult.fromJson deserializa totales de cuentas por pagar', () {
    final result = ImportPreviewResult.fromJson({
      'status': 'success',
      'isValid': true,
      'importType': 'accountsPayable',
      'totalRows': 4,
      'totalPayableAmount': 25000,
      'totalPayablePaid': 5000,
      'totalPayablePending': 20000,
      'newSuppliersCount': 2,
      'errors': const [],
    });

    expect(result.isValid, isTrue);
    expect(result.importType, 'accountsPayable');
    expect(result.totalRows, 4);
    expect(result.totalPayableAmount, 25000);
    expect(result.totalPayablePaid, 5000);
    expect(result.totalPayablePending, 20000);
    expect(result.newSuppliersCount, 2);
  });

  testWidgets('ImportPreviewDialog muestra resumen de totales de cuentas por pagar', (tester) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const preview = ImportPreviewResult(
      status: 'success',
      isValid: true,
      importType: 'accountsPayable',
      totalRows: 3,
      totalPayableAmount: 18050,
      totalPayablePaid: 5500,
      totalPayablePending: 12550,
      newSuppliersCount: 1,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ImportPreviewDialog(
            title: 'Importar cuentas por pagar',
            fileName: 'cuentas.csv',
            fileSizeBytes: 512,
            branchName: 'Sucursal Central',
            icon: Icons.request_quote_rounded,
            accentColor: Color(0xFFD97706),
            preview: preview,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('DOCUMENTOS'), findsOneWidget);
    expect(find.text('MONTO TOTAL'), findsOneWidget);
    expect(find.text('ABONADO'), findsOneWidget);
    expect(find.text('SALDO POR PAGAR'), findsOneWidget);
    expect(find.text('PROVEEDORES NUEVOS A CREAR'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });
}
