import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/view_controller.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/quick_commercial_product_search_delegate.dart';
import 'package:kardex_business/kardex_business.dart';

ProductInDbInBranch _buildBranchProduct({
  required String id,
  required ProductType productType,
  int currentStock = 0,
  int promiseStock = 0,
  String? branchId,
}) {
  final now = DateTime.fromMillisecondsSinceEpoch(1700000000000);
  return ProductInDbInBranch(
    id: id,
    name: 'Producto $id',
    unitName: 'Unidad',
    brandName: productType == ProductType.item ? 'MarcaX' : '',
    categoryName: 'General',
    tags: const [],
    hasIva: true,
    productType: productType,
    branchId: branchId,
    createdAt: now,
    account: ProductAccountInDb(
      productId: id,
      branchId: 'branch-1',
      currentStock: currentStock,
      promiseStock: promiseStock,
      averageCost: 0,
      lastCost: 0,
      maximumCost: 0,
      createdAt: now,
    ),
    saleProfile: ProductSaleProfileInDb(
      branchId: 'branch-1',
      productId: id,
      salePrice: 50000,
      salePrice2: 45000,
      salePrice3: 40000,
      salePrice4: 35000,
    ),
  );
}

void main() {
  group('ProductType enum', () {
    test('mapea valores API, flags tracksInventory/isService y fallback a item', () {
      expect(ProductType.fromJson('item'), ProductType.item);
      expect(ProductType.fromJson('nonInventory'), ProductType.nonInventory);
      expect(ProductType.fromJson('service'), ProductType.service);
      expect(ProductType.fromJson(null), ProductType.item);
      expect(ProductType.fromJson('unknown'), ProductType.item);
      expect(ProductType.fromJson(ProductType.service), ProductType.service);

      expect(ProductType.item.tracksInventory, isTrue);
      expect(ProductType.item.isService, isFalse);

      expect(ProductType.nonInventory.tracksInventory, isFalse);
      expect(ProductType.nonInventory.isService, isFalse);

      expect(ProductType.service.tracksInventory, isFalse);
      expect(ProductType.service.isService, isTrue);
    });
  });

  group('Serialización y retrocompatibilidad', () {
    test('ProductInDb y ProductInDbInBranch usan item por defecto si falta productType', () {
      final legacyProduct = ProductInDb.fromJson({
        'id': 'p-1',
        'name': 'Arroz',
        'unitName': 'Libra',
        'tags': <String>[],
        'hasIva': false,
        'createdAt': 1700000000000,
      });
      expect(legacyProduct.productType, ProductType.item);
      expect(legacyProduct.tracksInventory, isTrue);
      expect(legacyProduct.brandName, '');
      expect(legacyProduct.branchId, isNull);

      final serviceInBranch = ProductInDbInBranch.fromJson({
        'id': 'p-2',
        'name': 'Consulta médica',
        'unitName': 'Servicio',
        'tags': <String>[],
        'hasIva': false,
        'productType': 'service',
        'branchId': 'branch-1',
        'createdAt': 1700000000000,
        'account': {
          'productId': 'p-2',
          'branchId': 'branch-1',
          'currentStock': 0,
          'averageCost': 0,
          'lastCost': 0,
          'maximumCost': 0,
          'createdAt': 1700000000000,
        },
        'saleProfile': {
          'branchId': 'branch-1',
          'productId': 'p-2',
          'salePrice': 100000,
        },
      });
      expect(serviceInBranch.productType, ProductType.service);
      expect(serviceInBranch.isService, isTrue);
      expect(serviceInBranch.tracksInventory, isFalse);
      expect(serviceInBranch.branchId, 'branch-1');
      expect(serviceInBranch.toJson()['productType'], 'service');
    });

    test('ProductItem e InventoryProduct conservan productType y hacen fallback a item', () {
      final legacyItem = ProductItem.fromJson({
        'id': 'p-1',
        'name': 'Legado',
        'unitName': 'Unidad',
      });
      expect(legacyItem.productType, ProductType.item);
      expect(legacyItem.brandName, '');

      final nonInvItem = ProductItem.fromJson({
        'id': 'p-3',
        'name': 'Caramelo',
        'unitName': 'Unidad',
        'productType': 'nonInventory',
      });
      expect(nonInvItem.productType, ProductType.nonInventory);
      expect(nonInvItem.toJson()['productType'], 'nonInventory');

      final invProduct = InventoryProduct.fromJson({
        'id': 'p-4',
        'name': 'Soporte técnico',
        'unitName': 'Hora',
        'tags': <String>[],
        'productType': 'service',
      });
      expect(invProduct.productType, ProductType.service);
    });

    test('UpdateProduct solo envía branchId cuando se provee (conversión a servicio)', () {
      final plain = UpdateProduct.fromJson({
        'name': 'Consulta',
        'productType': 'item',
      });
      expect(plain.toJson().containsKey('branchId'), isFalse);

      final conversion = UpdateProduct.fromJson({
        'name': 'Consulta',
        'productType': 'service',
        'branchId': 'branch-1',
      });
      expect(conversion.toJson()['branchId'], 'branch-1');

      final create = CreateProduct.fromJson({
        'name': 'Consulta',
        'unitName': 'Unidad',
        'tags': <String>[],
        'hasIva': false,
        'productType': 'service',
        'branchId': 'branch-1',
      });
      expect(create.toJson()['branchId'], 'branch-1');
    });
  });

  group('resolveQuickItemQuantity', () {
    test('permite cantidad ilimitada cuando tracksInventory es false incluso con stock 0', () {
      final qtyService = resolveQuickItemQuantity(
        displayQuantity: 5,
        conversionFactor: 1,
        restrictStock: true,
        availableStock: 0,
        tracksInventory: false,
      );
      expect(qtyService, 5.0);

      final qtyInventoryNoStock = resolveQuickItemQuantity(
        displayQuantity: 5,
        conversionFactor: 1,
        restrictStock: true,
        availableStock: 0,
        tracksInventory: true,
      );
      expect(qtyInventoryNoStock, isNull);
    });
  });

  group('SaleTerminalViewController', () {
    testWidgets('permite agregar servicios y no inventariables con stock 0 y rechaza artículos sin stock', (
      tester,
    ) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final controller = SaleTerminalViewController();
      addTearDown(controller.dispose);

      final service = _buildBranchProduct(
        id: 'svc-1',
        productType: ProductType.service,
        currentStock: 0,
        branchId: 'branch-1',
      );
      final nonInv = _buildBranchProduct(
        id: 'ni-1',
        productType: ProductType.nonInventory,
        currentStock: 0,
        branchId: 'branch-1',
      );
      final itemZeroStock = _buildBranchProduct(
        id: 'item-0',
        productType: ProductType.item,
        currentStock: 0,
      );

      expect(controller.quickAddProduct(capturedContext, service), isTrue);
      expect(controller.quickAddProduct(capturedContext, service), isTrue);
      expect(controller.quickAddProduct(capturedContext, nonInv), isTrue);

      expect(controller.items.length, 2);
      expect(controller.items.firstWhere((e) => e.product.id == 'svc-1').quantity, 2.0);
      expect(controller.items.firstWhere((e) => e.product.id == 'ni-1').quantity, 1.0);

      controller.quickAddItem(
        CommercialProductResult(product: nonInv),
      );
      expect(controller.items.firstWhere((e) => e.product.id == 'ni-1').quantity, 2.0);

      expect(controller.quickAddProduct(capturedContext, itemZeroStock), isFalse);
      await tester.pump();
    });
  });
}
