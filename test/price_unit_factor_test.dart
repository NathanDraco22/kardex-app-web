import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/widgets/dialogs/create_product_with_data_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_app_front/widgets/elements/price_level_sync_controller.dart';
import 'package:kardex_business/kardex_business.dart';

ProductInDbInBranch _buildLibraCentesimalProduct({
  int salePrice = 1850,
  int averageCost = 1450,
  int currentStock = 10000,
  int priceUnitFactor = 100,
}) {
  final now = DateTime(2026, 11, 23);
  return ProductInDbInBranch(
    id: 'prod-arroz',
    name: 'Arroz',
    unitName: '0.01 Libra',
    categoryName: 'Granos',
    tags: const [],
    hasIva: false,
    extraUnits: const [
      ExtraUnit(name: 'Libra', conversionFactor: 100),
      ExtraUnit(name: 'Arroba (25 lb)', conversionFactor: 2500),
      ExtraUnit(name: 'Quintal (100 lb)', conversionFactor: 10000),
    ],
    defaultUnitIndex: 1,
    wholesaleUnitIndex: 3,
    priceUnitFactor: priceUnitFactor,
    createdAt: now,
    account: ProductAccountInDb(
      branchId: 'b1',
      productId: 'prod-arroz',
      currentStock: currentStock,
      averageCost: averageCost,
      lastCost: averageCost,
      maximumCost: averageCost,
      createdAt: now,
    ),
    saleProfile: ProductSaleProfileInDb(
      branchId: 'b1',
      productId: 'prod-arroz',
      salePrice: salePrice,
      salePrice2: 1800,
      salePrice3: 1750,
      salePrice4: 1700,
    ),
  );
}

void main() {
  group('UnitConversionTool con priceUnitFactor', () {
    test('mantiene retrocompatibilidad exacta con priceUnitFactor = 1', () {
      expect(UnitConversionTool.toStoredPriceOrCost(2000, 4), 500);
      expect(UnitConversionTool.toDisplayPriceOrCost(500, 4), 2000);
      expect(UnitConversionTool.calculateLineTotal(500, 40), 20000);
    });

    test('calcula precios, costos y totales exactos con priceUnitFactor = 100', () {
      // 18.50 por Libra (factor 100) se guarda exacto como 1850
      expect(
        UnitConversionTool.toStoredPriceOrCost(1850, 100, priceUnitFactor: 100),
        1850,
      );
      // 1 Quintal (factor 10000) a 1450.00 -> 14.50/lb (1450¢)
      expect(
        UnitConversionTool.toStoredPriceOrCost(145000, 10000, priceUnitFactor: 100),
        1450,
      );
      // Mostrar 1 Arroba (factor 2500) a 18.50/lb -> 462.50 (46250¢)
      expect(
        UnitConversionTool.toDisplayPriceOrCost(1850, 2500, priceUnitFactor: 100),
        46250,
      );
      // 1.35 lb (135 centésimas) a 18.50/lb -> 24.975 -> 2498¢
      expect(
        UnitConversionTool.calculateLineTotal(1850, 135, priceUnitFactor: 100),
        2498,
      );
      // Caso exacto .5 con parte entera par: 18.50/lb × 0.25 lb = 462.5¢ -> 463¢ (half-up)
      expect(
        UnitConversionTool.calculateLineTotal(1850, 25, priceUnitFactor: 100),
        463,
      );
      // Caso negativo half-away-from-zero: -462.5¢ -> -463¢
      expect(
        UnitConversionTool.calculateLineTotal(1850, -25, priceUnitFactor: 100),
        -463,
      );
      // 0.10 lb (10 centésimas) a 18.50/lb -> 185¢ exacto
      expect(
        UnitConversionTool.calculateLineTotal(1850, 10, priceUnitFactor: 100),
        185,
      );
    });
  });

  group('CommercialProductResult con priceUnitFactor = 100', () {
    test('calcula subTotal exacto para 0.1 lb, 0.25 lb, 1.35 lb y 2 Arrobas', () {
      final product = _buildLibraCentesimalProduct();
      final result = CommercialProductResult(product: product);

      expect(result.conversionFactor, 100);
      expect(result.selectedUnitName, 'Libra');

      result.quantity = 0.1;
      expect(result.baseQuantity, 10);
      expect(result.subTotal, 185);

      result.quantity = 0.25;
      expect(result.baseQuantity, 25);
      expect(result.subTotal, 463);

      result.quantity = 1.35;
      expect(result.baseQuantity, 135);
      expect(result.subTotal, 2498);

      // Cambiar a Arroba (factor 2500) y vender 2 Arrobas = 50 lb
      result.selectedUnitIndex = 2;
      result.conversionFactor = 2500;
      result.selectedUnitName = 'Arroba (25 lb)';
      result.quantity = 2;
      expect(result.baseQuantity, 5000);
      expect(result.subTotal, 92500);
    });
  });

  group('PriceLevelSyncController con priceUnitFactor = 100', () {
    test('sincroniza Libra y Arroba sin perder centavos', () {
      final product = _buildLibraCentesimalProduct(salePrice: 1850);
      final controller = PriceLevelSyncController(
        initialPrices: const [1850, 1800, 1750, 1700],
        extraUnits: product.extraUnits,
        defaultUnitIndex: product.defaultUnitIndex,
        wholesaleUnitIndex: product.wholesaleUnitIndex,
        priceUnitFactor: product.priceUnitFactor,
      );
      addTearDown(controller.dispose);

      // Unidad inicial: Libra (factor 100 == priceUnitFactor 100) -> 18.50 exacto
      expect(controller.selectedUnit?.name, 'Libra');
      expect(controller.extraControllers[0].text, '18.50');

      // Cambiar a Arroba (factor 2500) -> 18.50 * 25 = 462.50 exacto
      controller.selectUnit(product.extraUnits[1]);
      expect(controller.extraControllers[0].text, '462.50');

      // Editar precio por Arroba a 500.00 -> precio por Libra = 20.00 (2000¢)
      controller.onExtraChanged(0, '500.00');
      expect(controller.prices[0], 2000);
      expect(controller.baseControllers[0].text, '20.00');
    });
  });

  group('Modelos de documentos e inventario', () {
    test('SaleItem, EntryItem, TransferItem e InventoryInDb respetan priceUnitFactor', () {
      final saleItem = SaleItem(
        product: ProductItem(id: 'p1', name: 'Arroz', unitName: '0.01 Libra'),
        selectedPrice: 1,
        quantity: 135,
        cost: 1450,
        price: 1850,
        subTotal: 2498,
        total: 2498,
        conversionFactor: 100,
        priceUnitFactor: 100,
        selectedUnitName: 'Libra',
        standardUnitName: 'Libra',
        standardUnitFactor: 100,
      );
      expect(saleItem.displayUnitPrice, 1850);
      expect(saleItem.lineCost, 1958);

      final entryItem = EntryItem(
        productId: 'p1',
        productName: 'Arroz',
        cost: 1450,
        quantity: 10000,
        conversionFactor: 10000,
        priceUnitFactor: 100,
        unitName: 'Quintal (100 lb)',
        standardUnitName: 'Libra',
        standardUnitFactor: 100,
      );
      expect(entryItem.displayUnitCost, 145000);
      expect(entryItem.lineTotal, 145000);

      final transferItem = TransferItem(
        id: 'p1',
        name: 'Arroz',
        unitName: '0.01 Libra',
        brandName: '',
        quantity: 2500,
        cost: 1450,
        conversionFactor: 2500,
        priceUnitFactor: 100,
        selectedUnitName: 'Arroba (25 lb)',
        standardUnitName: 'Libra',
        standardUnitFactor: 100,
        salePrice: 1850,
        salePrice2: 0,
        salePrice3: 0,
        salePrice4: 0,
      );
      expect(transferItem.displayUnitCost, 36250);
      expect(transferItem.lineTotal, 36250);

      final inventory = InventoryInDb(
        branchId: 'b1',
        product: InventoryProduct(
          id: 'p1',
          name: 'Arroz',
          unitName: '0.01 Libra',
          tags: const [],
          priceUnitFactor: 100,
        ),
        currentStock: 250,
        averageCost: 1850,
        lastCost: 1850,
        createdAt: DateTime(2026, 11, 23),
      );
      // 2.50 lb a 18.50/lb = 46.25 (4625¢)
      expect(inventory.total, 4625);
    });

    test('retrocompatibilidad JSON: ausencia de priceUnitFactor usa 1', () {
      final prod = BaseProduct.fromJson({
        'name': 'Producto Viejo',
        'unitName': '1/4 Libra',
        'tags': <String>[],
        'hasIva': false,
      });
      expect(prod.priceUnitFactor, 1);

      final scale = BaseUnitScale.fromJson({
        'name': 'Escala Vieja',
        'baseUnit': 'Unidad',
      });
      expect(scale.priceUnitFactor, 1);
    });
  });

  group('buildInitialInventoryInfo (CreateProductWithDataDialog)', () {
    test('convierte cantidad decimal y conserva precio/costo exacto en Libra (Decimal)', () {
      final product = CreateProduct(
        name: 'Lomo de Res',
        unitName: '0.01 Libra',
        categoryName: 'Carnes',
        tags: const [],
        hasIva: false,
        extraUnits: const [
          ExtraUnit(name: 'Libra', conversionFactor: 100),
        ],
        defaultUnitIndex: 1,
        priceUnitFactor: 100,
      );

      final info = buildInitialInventoryInfo(
        createProduct: product,
        tracksInventory: true,
        quantityText: '12.5',
        costText: '14.50',
        priceText: '18.50',
      );

      expect(info.quantity, 1250);
      expect(info.cost, 1450);
      expect(info.price, 1850);
    });

    test('convierte cantidad, costo y precio en escala de cuartos (1/4 Libra)', () {
      final product = CreateProduct(
        name: 'Queso',
        unitName: '1/4 Libra',
        categoryName: 'Lácteos',
        tags: const [],
        hasIva: false,
        extraUnits: const [
          ExtraUnit(name: 'Libra', conversionFactor: 4),
        ],
        defaultUnitIndex: 1,
        priceUnitFactor: 1,
      );

      final info = buildInitialInventoryInfo(
        createProduct: product,
        tracksInventory: true,
        quantityText: '1.25',
        costText: '16.00',
        priceText: '20.00',
      );

      expect(info.quantity, 5);
      expect(info.cost, 400);
      expect(info.price, 500);
    });

    test('mantiene enteros y montos directos en unidad simple (factor 1)', () {
      final product = CreateProduct(
        name: 'Refresco',
        unitName: 'Unidad',
        categoryName: 'Bebidas',
        tags: const [],
        hasIva: false,
      );

      final info = buildInitialInventoryInfo(
        createProduct: product,
        tracksInventory: true,
        quantityText: '10',
        costText: '12.00',
        priceText: '15.00',
      );

      expect(info.quantity, 10);
      expect(info.cost, 1200);
      expect(info.price, 1500);
    });
  });
}
