import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/widget/pending_invoices_statement_image_dialog.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/widget/pending_invoices_statement_options_dialog.dart';
import 'package:kardex_app_front/src/tools/exports/file_save_helper.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/pending_invoices_statement_template.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

ClientInDb _buildClient() {
  return ClientInDb(
    id: 'client-1',
    name: 'Comercial El Éxito',
    group: 'General',
    cardId: '001-010190-0001A',
    phone: '8888-1111',
    location: 'Managua, Nicaragua',
    createdAt: DateTime(2026, 1, 1),
  );
}

BranchInDb _buildBranch() {
  return BranchInDb(
    id: 'branch-1',
    name: 'Sucursal Central',
    idCard: 'J0310000000001',
    address: 'Av. Principal #100',
    email: 'sucursal@example.com',
    phone: '2222-3333',
    createdAt: DateTime(2026, 1, 1),
  );
}

InvoiceInDb _buildPendingInvoice() {
  return InvoiceInDb(
    id: 'inv-1',
    branchId: 'branch-1',
    clientId: 'client-1',
    clientInfo: ClientInfo(
      name: 'Comercial El Éxito',
      group: 'General',
    ),
    docNumber: 'F-0042',
    saleItems: const [],
    status: InvoiceStatus.open,
    paymentType: PaymentType.credit,
    bankReference: '',
    totalCost: 10000,
    total: 15000,
    amountPaid: 5000,
    createdAt: DateTime(2026, 11, 20),
    createdBy: const UserInfo(id: 'user-1', name: 'Vendedor'),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  test('FileSaveHelper.buildStatementFileName sanitizes client name', () {
    final fileName = FileSaveHelper.buildStatementFileName(
      prefix: 'estado_cuenta',
      clientName: 'Cliente / Demo #1!',
      date: DateTime(2026, 11, 26),
    );
    expect(fileName, 'estado_cuenta_Cliente_Demo_1_2026-11-26');
  });

  test('PendingInvoicesStatementPdfTemplate builds a valid PDF document', () async {
    final template = PendingInvoicesStatementPdfTemplate(
      client: _buildClient(),
      branch: _buildBranch(),
      invoices: [_buildPendingInvoice()],
      devolutions: const [],
      creditNotes: const [],
    );

    final doc = await template.buildDocument();
    final bytes = await doc.save();

    expect(bytes.length, greaterThan(500));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  testWidgets('PendingInvoicesStatementOptionsDialog shows PDF and Imagen options', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showPendingInvoicesStatementOptionsDialog(
                  context: context,
                  client: _buildClient(),
                  invoices: [_buildPendingInvoice()],
                  devolutions: const [],
                  creditNotes: const [],
                  branch: _buildBranch(),
                );
              },
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Estado de Cuenta'), findsOneWidget);
    expect(find.text('PDF'), findsOneWidget);
    expect(find.text('Imagen'), findsOneWidget);
    expect(find.text('Descargar'), findsOneWidget);
    expect(find.text('Compartir'), findsOneWidget);
    expect(find.text('Ver, Descargar o Compartir'), findsOneWidget);
  });

  testWidgets('PendingInvoicesStatementImageDialog exposes Descargar and Compartir buttons', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showPendingInvoicesStatementImageDialog(
                  context: context,
                  client: _buildClient(),
                  invoices: [_buildPendingInvoice()],
                  devolutions: const [],
                  creditNotes: const [],
                );
              },
              child: const Text('Abrir Imagen'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir Imagen'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Descargar'), findsOneWidget);
    expect(find.text('Compartir'), findsOneWidget);
  });
}
