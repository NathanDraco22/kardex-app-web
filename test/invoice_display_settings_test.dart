import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/single_invoice_template.dart';
import 'package:kardex_app_front/src/tools/printers/invoice_printer.dart';
import 'package:kardex_app_front/src/tools/printers/paper_settings.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/invoice_viewer.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

BranchInDb _buildBranch() {
  return BranchInDb(
    id: 'branch-1',
    name: 'Sucursal Central',
    idCard: 'J0310000000001',
    address: 'Av. Principal #100',
    email: 'sucursal@example.com',
    phone: '8888-8888',
    createdAt: DateTime(2026, 1, 1),
  );
}

InvoiceInDb _buildInvoice({OrderInfo? orderInfo, UserInfo? invoicedBy}) {
  final now = DateTime(2026, 11, 26, 10, 30);
  return InvoiceInDb(
    id: 'inv-1',
    branchId: 'branch-1',
    clientId: 'client-1',
    clientInfo: ClientInfo(
      name: 'Cliente Demo',
      group: 'General',
      phone: '7777-7777',
      address: 'Dirección Demo',
    ),
    docNumber: 'F-0001',
    orderNumber: orderInfo?.docNumber ?? '',
    orderInfo: orderInfo,
    saleItems: [
      SaleItem(
        product: ProductItem(
          id: 'p-1',
          name: 'Arroz Blanco',
          unitName: 'Onza',
        ),
        selectedPrice: 1,
        quantity: 200,
        bonQuantity: 100,
        cost: 50,
        price: 100,
        subTotal: 20000,
        total: 20000,
        conversionFactor: 100,
        selectedUnitName: 'Libra',
        standardUnitName: 'Libra',
        standardUnitFactor: 100,
      ),
      SaleItem(
        product: ProductItem(
          id: 'p-2',
          name: 'Azúcar Refinada',
          unitName: 'Onza',
        ),
        selectedPrice: 1,
        quantity: 150,
        bonQuantity: 0,
        cost: 40,
        price: 80,
        subTotal: 12000,
        total: 12000,
        conversionFactor: 100,
        selectedUnitName: 'Libra',
        standardUnitName: 'Libra',
        standardUnitFactor: 100,
      ),
    ],
    status: InvoiceStatus.paid,
    paymentType: PaymentType.cash,
    bankReference: '',
    totalCost: 16000,
    total: 32000,
    createdAt: now,
    createdBy: const UserInfo(
      id: 'user-1',
      name: 'Cajero Principal',
    ),
    invoicedBy: invoicedBy,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('invoice_display_settings_test_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    BaseInvoice.configureDisplayConfigResolver(null);
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('AppSettingModel & UpdateAppSetting invoice display fields', () {
    test('defaults are false even for legacy JSON payloads', () {
      const defaults = AppSettingModel(id: 'Default', createdAt: 1700000000000);
      expect(defaults.showInvoiceItemsSummary, isFalse);
      expect(defaults.showInvoiceOrderCreator, isFalse);
      expect(defaults.chargeConvertedOrdersToShift, isFalse);

      final fromLegacy = AppSettingModel.fromJson({
        'id': 'Default',
        'createdAt': 1700000000000,
      });
      expect(fromLegacy.showInvoiceItemsSummary, isFalse);
      expect(fromLegacy.showInvoiceOrderCreator, isFalse);
      expect(fromLegacy.chargeConvertedOrdersToShift, isFalse);
      expect(fromLegacy.toJson()['showInvoiceItemsSummary'], isFalse);
      expect(fromLegacy.toJson()['showInvoiceOrderCreator'], isFalse);
      expect(fromLegacy.toJson()['chargeConvertedOrdersToShift'], isFalse);

      final copied = fromLegacy.copyWith(
        showInvoiceItemsSummary: true,
        showInvoiceOrderCreator: true,
        chargeConvertedOrdersToShift: true,
      );
      expect(copied.showInvoiceItemsSummary, isTrue);
      expect(copied.showInvoiceOrderCreator, isTrue);
      expect(copied.chargeConvertedOrdersToShift, isTrue);

      const update = UpdateAppSetting(
        showInvoiceItemsSummary: true,
        chargeConvertedOrdersToShift: true,
      );
      expect(update.toJson(), {
        'showInvoiceItemsSummary': true,
        'chargeConvertedOrdersToShift': true,
      });
    });
  });

  group('BaseInvoice items summary getters', () {
    test('counts items and sums displayQuantity + displayBonQuantity', () {
      final invoice = _buildInvoice();
      expect(invoice.totalItemsCount, 2);
      expect(invoice.totalItemsQuantity, closeTo(4.5, 0.0001));
      expect(invoice.formattedTotalItemsQuantity, '4.5');
    });
  });

  group('InvoiceViewerContent displayConfig', () {
    testWidgets('hides items summary and order creator by default, keeps payment method', (
      tester,
    ) async {
      final invoice = _buildInvoice(
        orderInfo: OrderInfo(
          id: 'ord-1',
          docNumber: 'ORD-10',
          createdAt: DateTime(2026, 11, 26, 9, 0),
          createdBy: const UserInfo(
            id: 'seller-1',
            name: 'Carlos Vendedor',
          ),
        ),
        invoicedBy: const UserInfo(
          id: 'cashier-1',
          name: 'María Cajera',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InvoiceViewerContent(
              invoice: invoice,
              branch: _buildBranch(),
              displayConfig: const InvoiceDisplayConfig(),
            ),
          ),
        ),
      );

      expect(find.text('Contado'), findsOneWidget);
      expect(find.text('Pedido No. ORD-10'), findsOneWidget);
      expect(find.textContaining('Tomado por:'), findsNothing);
      expect(find.textContaining('Facturado por:'), findsNothing);
      expect(find.textContaining('Total ítems:'), findsNothing);
      expect(find.textContaining('Total cantidad:'), findsNothing);
    });

    testWidgets('shows items summary and order creator when enabled', (tester) async {
      final invoice = _buildInvoice(
        orderInfo: OrderInfo(
          id: 'ord-1',
          docNumber: 'ORD-10',
          createdAt: DateTime(2026, 11, 26, 9, 0),
          createdBy: const UserInfo(
            id: 'seller-1',
            name: 'Carlos Vendedor',
          ),
        ),
        invoicedBy: const UserInfo(
          id: 'cashier-1',
          name: 'María Cajera',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InvoiceViewerContent(
              invoice: invoice,
              branch: _buildBranch(),
              displayConfig: const InvoiceDisplayConfig(
                showItemsSummary: true,
                showOrderCreator: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Contado'), findsOneWidget);
      expect(find.text('Tomado por: Carlos Vendedor'), findsOneWidget);
      expect(find.text('Facturado por: María Cajera'), findsOneWidget);
      expect(find.text('Total ítems: 2'), findsOneWidget);
      expect(find.text('Total cantidad: 4.5'), findsOneWidget);

      final json = invoice.toJson();
      final reparsed = InvoiceInDb.fromJson(json);
      expect(reparsed.invoicedBy?.id, 'cashier-1');
      expect(reparsed.invoicedBy?.name, 'María Cajera');
    });
  });

  group('Thermal ticket and A4 PDF generation', () {
    test('generates 58mm, 80mm tickets and A4 PDF with both configs', () async {
      final branch = _buildBranch();
      final invoice = _buildInvoice(
        orderInfo: OrderInfo(
          id: 'ord-1',
          docNumber: 'ORD-10',
          createdAt: DateTime(2026, 11, 26, 9, 0),
          createdBy: const UserInfo(
            id: 'seller-1',
            name: 'Carlos Vendedor',
          ),
        ),
        invoicedBy: const UserInfo(
          id: 'cashier-1',
          name: 'María Cajera',
        ),
      );

      for (final config in const [
        InvoiceDisplayConfig(),
        InvoiceDisplayConfig(showItemsSummary: true, showOrderCreator: true),
      ]) {
        for (final size in const [PaperSize.mm58, PaperSize.mm80]) {
          final ticketBytes = await generateTicketPdfFromInvoice(
            invoice,
            branch,
            paperSize: size,
            displayConfig: config,
          );
          expect(ticketBytes, isNotEmpty);
        }

        final a4Doc = await SingleInvoiceTemplate(
          invoice: invoice,
          branch: branch,
          displayConfig: config,
        ).buildDocument();
        final a4Bytes = await a4Doc.save();
        expect(a4Bytes, isNotEmpty);
      }
    });
  });
}
