import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/widgets/dialogs/inventory_unit_picker.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/widgets/commercial_product_unit_selector.dart';
import 'package:kardex_business/kardex_business.dart';

ProductInDbInBranch _buildProduct({
  bool showBasicUnit = true,
  int defaultUnitIndex = 0,
  List<ExtraUnit> extraUnits = const [
    ExtraUnit(name: 'Libra', conversionFactor: 100),
    ExtraUnit(name: 'Quintal', conversionFactor: 10000),
  ],
}) {
  final now = DateTime(2026, 11, 26);
  return ProductInDbInBranch(
    id: 'prod-1',
    name: 'Arroz',
    code: 'ARZ-01',
    unitName: '0.01 Libra',
    categoryName: 'Granos',
    brandName: 'Marca',
    tags: const [],
    extraUnits: extraUnits,
    defaultUnitIndex: defaultUnitIndex,
    wholesaleUnitIndex: 0,
    showBasicUnit: showBasicUnit,
    hasIva: false,
    productType: ProductType.item,
    createdAt: now,
    saleProfile: ProductSaleProfileInDb(
      productId: 'prod-1',
      branchId: 'branch-1',
      salePrice: 100,
      salePrice2: 90,
      salePrice3: 80,
      salePrice4: 70,
    ),
    account: ProductAccountInDb(
      productId: 'prod-1',
      branchId: 'branch-1',
      currentStock: 5000,
      promiseStock: 0,
      averageCost: 50,
      lastCost: 50,
      maximumCost: 50,
      createdAt: now,
    ),
  );
}

void main() {
  group('showBasicUnit en modelos', () {
    test('default true cuando falta en JSON y respeta false en roundtrip', () {
      final nowMs = DateTime(2026, 11, 26).millisecondsSinceEpoch;
      final baseScale = BaseUnitScale.fromJson({
        'name': 'Peso 0.01 lb',
        'baseUnit': '0.01 Libra',
        'units': [
          {'name': 'Libra', 'conversionFactor': 100},
        ],
      });
      expect(baseScale.showBasicUnit, isTrue);

      final scaleFalse = UnitScaleInDb.fromJson({
        'id': 'scale-1',
        'name': 'Peso 0.01 lb',
        'baseUnit': '0.01 Libra',
        'showBasicUnit': false,
        'createdAt': nowMs,
      });
      expect(scaleFalse.showBasicUnit, isFalse);
      expect(scaleFalse.toJson()['showBasicUnit'], isFalse);

      final invProd = InventoryProduct.fromJson({
        'id': 'prod-1',
        'name': 'Arroz',
        'unitName': '0.01 Libra',
        'tags': <String>[],
        'showBasicUnit': false,
      });
      expect(invProd.showBasicUnit, isFalse);
      expect(invProd.toJson()['showBasicUnit'], isFalse);
    });
  });

  group('CommercialProductResult y CommercialProductUnitSelector', () {
    test('hace fallback a extraUnits[0] si showBasicUnit es false y defaultUnitIndex es 0', () {
      final product = _buildProduct(showBasicUnit: false, defaultUnitIndex: 0);
      final result = CommercialProductResult(product: product);

      expect(result.selectedUnitIndex, 1);
      expect(result.conversionFactor, 100);
      expect(result.selectedUnitName, 'Libra');
    });

    testWidgets('oculta la unidad base en DropdownButtonFormField cuando showBasicUnit es false', (tester) async {
      final product = _buildProduct(showBasicUnit: false, defaultUnitIndex: 0);
      final result = CommercialProductResult(product: product);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommercialProductUnitSelector(
              result: result,
              onChanged: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();

      expect(find.text('0.01 Libra'), findsNothing);
      expect(find.text('Libra'), findsWidgets);
      expect(find.text('Quintal'), findsWidgets);
    });

    testWidgets('muestra la unidad base cuando showBasicUnit es true', (tester) async {
      final product = _buildProduct(showBasicUnit: true, defaultUnitIndex: 1);
      final result = CommercialProductResult(product: product);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommercialProductUnitSelector(
              result: result,
              onChanged: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();

      expect(find.text('0.01 Libra'), findsWidgets);
      expect(find.text('Libra'), findsWidgets);
      expect(find.text('Quintal'), findsWidgets);
    });
  });

  group('showInventoryUnitPicker', () {
    testWidgets('retorna directamente la unica unidad extra si showBasicUnit es false', (tester) async {
      final product = _buildProduct(
        showBasicUnit: false,
        extraUnits: const [ExtraUnit(name: 'Libra', conversionFactor: 100)],
      );
      UnitPickerResult? picked;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  picked = await showInventoryUnitPicker(context, product);
                },
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Seleccionar Unidad'), findsNothing);
      expect(picked, isNotNull);
      expect(picked!.unitIndex, 1);
      expect(picked!.conversionFactor, 100);
      expect(picked!.unitName, 'Libra');
    });

    testWidgets('oculta la unidad base en el dialogo cuando hay multiples extras y showBasicUnit es false', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final product = _buildProduct(showBasicUnit: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showInventoryUnitPicker(context, product);
                },
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Seleccionar Unidad'), findsOneWidget);
      expect(find.text('0.01 Libra'), findsNothing);
      expect(find.text('Libra'), findsWidgets);
      expect(find.text('Quintal'), findsOneWidget);
    });
  });
}
