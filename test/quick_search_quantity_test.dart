import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/quick_commercial_product_search_delegate.dart';
import 'package:kardex_business/kardex_business.dart';

void main() {
  group('resolveQuickItemQuantity', () {
    test('stock 0 con restrictStock no inserta cantidad 1', () {
      expect(
        resolveQuickItemQuantity(
          displayQuantity: 1,
          conversionFactor: 1,
          restrictStock: true,
          availableStock: 0,
        ),
        isNull,
      );
    });

    test('cantidad 0.1 con factor 4 produce base 0 y no se inserta', () {
      expect(
        resolveQuickItemQuantity(
          displayQuantity: 0.1,
          conversionFactor: 4,
          restrictStock: false,
          availableStock: 100,
        ),
        isNull,
      );
    });

    test('cantidad 0.5 con factor 4 produce base 2 y se inserta', () {
      expect(
        resolveQuickItemQuantity(
          displayQuantity: 0.5,
          conversionFactor: 4,
          restrictStock: true,
          availableStock: 100,
        ),
        0.5,
      );
    });

    test('cantidad 0 no se inserta', () {
      expect(
        resolveQuickItemQuantity(
          displayQuantity: 0,
          conversionFactor: 1,
          restrictStock: false,
          availableStock: 100,
        ),
        isNull,
      );
    });

    test('stock 0 sin restrictStock permite cantidad positiva', () {
      expect(
        resolveQuickItemQuantity(
          displayQuantity: 1,
          conversionFactor: 1,
          restrictStock: false,
          availableStock: 0,
        ),
        1,
      );
    });
  });

  group('QuickProductSearchDelegate', () {
    testWidgets('clamp a 0 con texto previo deja el controller vacío', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: QuickProductSearchDelegate(
            restrictStock: true,
            initialProducts: [_buildProduct(stock: 0)],
          ),
        ),
      );

      final quantityField = find.descendant(
        of: find.byType(ListView),
        matching: find.byType(TextField),
      );
      await tester.enterText(quantityField, '1');
      await tester.pump();

      final controller = tester.widget<TextField>(quantityField).controller!;
      expect(controller.text, isEmpty);
    });
  });
}

ProductInDbInBranch _buildProduct({required int stock}) {
  final now = DateTime(2026, 1, 1);
  return ProductInDbInBranch(
    id: 'product-1',
    name: 'Producto',
    brandName: 'Marca',
    unitName: 'Unidad',
    categoryName: 'Categoría',
    tags: const [],
    hasIva: false,
    createdAt: now,
    account: ProductAccountInDb(
      productId: 'product-1',
      branchId: 'branch-1',
      currentStock: stock,
      averageCost: 0,
      lastCost: 0,
      maximumCost: 0,
      createdAt: now,
    ),
    saleProfile: ProductSaleProfileInDb(
      branchId: 'branch-1',
      productId: 'product-1',
      salePrice: 100,
      salePrice2: 100,
      salePrice3: 100,
      salePrice4: 100,
    ),
  );
}
