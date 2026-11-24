import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/widgets/terminal_cart_item_tile.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/order_viewer.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

ProductInDbInBranch _buildTestProduct() {
  final now = DateTime(2026, 11, 24, 14, 30);
  return ProductInDbInBranch(
    id: 'prod-1',
    name: 'Producto de Prueba',
    code: 'P-001',
    unitName: 'Unidad',
    categoryName: 'General',
    brandName: 'Marca',
    tags: const [],
    extraUnits: const [],
    defaultUnitIndex: 0,
    wholesaleUnitIndex: 0,
    hasIva: false,
    productType: ProductType.item,
    createdAt: now,
    saleProfile: ProductSaleProfileInDb(
      productId: 'prod-1',
      branchId: 'branch-1',
      salePrice: 10000,
      salePrice2: 9000,
      salePrice3: 8000,
      salePrice4: 7000,
    ),
    account: ProductAccountInDb(
      productId: 'prod-1',
      branchId: 'branch-1',
      currentStock: 50,
      promiseStock: 0,
      averageCost: 5000,
      lastCost: 5000,
      maximumCost: 5000,
      createdAt: now,
    ),
  );
}

BranchInDb _buildTestBranch() {
  return BranchInDb(
    id: 'branch-1',
    name: 'Sucursal Central',
    idCard: 'J0310000000001',
    address: 'Calle Principal',
    email: 'sucursal@example.com',
    phone: '8888-8888',
    createdAt: DateTime(2026, 1, 1),
  );
}

OrderInDb _buildTestOrder({String description = ''}) {
  return OrderInDb(
    id: 'ord-1',
    branchId: 'branch-1',
    clientId: 'cli-1',
    clientInfo: ClientInfo(name: 'Cliente Demo', group: 'General'),
    docNumber: 'PED-001',
    saleItems: const [],
    description: description,
    status: OrderStatus.open,
    paymentType: PaymentType.cash,
    totalCost: 0,
    total: 10000,
    createdAt: DateTime(2026, 11, 24, 14, 35),
    createdBy: const UserInfo(id: 'usr-1', name: 'Vendedor Demo'),
  );
}

void main() {
  group('TerminalCartItemTile badge de nivel de precio', () {
    final cases = <int, String>{
      1: 'P1',
      2: 'P2',
      3: 'P3',
      4: 'P4',
      0: 'Manual',
    };

    for (final entry in cases.entries) {
      testWidgets('muestra "${entry.value}" cuando selectedPriceLevel es ${entry.key}', (tester) async {
        final result = CommercialProductResult(
          product: _buildTestProduct(),
          defaultPriceLevel: entry.key == 0 ? 1 : entry.key,
        );
        result.selectedPriceLevel = entry.key;
        result.quantity = 1;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TerminalCartItemTile(
                item: result,
                backgroundColor: Colors.white,
                onRemove: () {},
                onEdit: () {},
                onQuantityIncrement: () {},
                onQuantityDecrement: () {},
              ),
            ),
          ),
        );

        expect(find.text(entry.value), findsOneWidget);
      });
    }
  });

  group('OrderViewerContent observaciones', () {
    testWidgets('muestra la observación cuando description no está vacío', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 600,
              child: OrderViewerContent(
                order: _buildTestOrder(description: 'Entregar en puerta trasera'),
                branch: _buildTestBranch(),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Observación: Entregar en puerta trasera'), findsOneWidget);
    });

    testWidgets('no muestra Observación cuando description está vacío', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 600,
              child: OrderViewerContent(
                order: _buildTestOrder(description: '   '),
                branch: _buildTestBranch(),
              ),
            ),
          ),
        ),
      );

      expect(find.textContaining('Observación:'), findsNothing);
    });
  });
}
