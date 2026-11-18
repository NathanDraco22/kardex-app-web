import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_state.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_app_front/widgets/gates/gates.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

class _FakeAppSettingsDataSource implements AppSettingsDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository() : super(_FakeAppSettingsDataSource());
}

ProductInDbInBranch _buildProduct() {
  final now = DateTime(2026);
  return ProductInDbInBranch(
    id: 'prod-1',
    name: 'Producto Prueba',
    code: 'P-001',
    unitName: 'UND',
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
      salePrice3: 8500,
      salePrice4: 8000,
      discounts: [
        Discount(name: 'VIP', percentValue: 10, isActive: true),
      ],
    ),
    account: ProductAccountInDb(
      productId: 'prod-1',
      branchId: 'branch-1',
      currentStock: 100,
      promiseStock: 0,
      averageCost: 5000,
      lastCost: 5000,
      maximumCost: 5000,
      createdAt: now,
    ),
  );
}

void main() {
  group('DiscountType & Models', () {
    test('calculateDiscountAmount computes percentage and clamps amount', () {
      expect(
        DiscountType.calculateDiscountAmount(
          type: DiscountType.percentage,
          discountValue: 15,
          baseAmount: 10000,
        ),
        1500,
      );
      expect(
        DiscountType.calculateDiscountAmount(
          type: DiscountType.amount,
          discountValue: 2500,
          baseAmount: 10000,
        ),
        2500,
      );
      expect(
        DiscountType.calculateDiscountAmount(
          type: DiscountType.amount,
          discountValue: 15000,
          baseAmount: 10000,
        ),
        10000,
      );
      expect(
        DiscountType.formatEquivalentPercentage(
          discountAmount: 5000,
          baseAmount: 50000,
        ),
        '10%',
      );
      expect(
        DiscountType.formatEquivalentPercentage(
          discountAmount: 5000,
          baseAmount: 40000,
        ),
        '12.5%',
      );
    });

    test('SaleItem.fromJson infers discountType for legacy items', () {
      final legacyPct = SaleItem.fromJson({
        'product': {
          'id': 'p1',
          'name': 'Prod',
          'unitName': 'UND',
        },
        'selectedPrice': 1,
        'quantity': 1,
        'cost': 500,
        'price': 10000,
        'subTotal': 10000,
        'discountPercentage': 10,
        'totalDiscount': 1000,
        'total': 9000,
      });
      expect(legacyPct.discountType, DiscountType.percentage);

      final amountItem = SaleItem(
        product: ProductItem(id: 'p1', name: 'Prod', unitName: 'UND'),
        selectedPrice: 1,
        quantity: 1,
        cost: 500,
        price: 10000,
        subTotal: 10000,
        discountType: DiscountType.amount,
        discountPercentage: 0,
        totalDiscount: 1200,
        total: 8800,
      );
      final parsed = SaleItem.fromJson(amountItem.toJson());
      expect(parsed.discountType, DiscountType.amount);
      expect(parsed.totalDiscount, 1200);
      expect(parsed.discountPercentage, 0);
    });

    test('InvoiceInDb exposes itemDiscounts, invoiceDiscount and totalDiscount', () {
      final inv = InvoiceInDb.fromJson({
        'id': 'inv-1',
        'branchId': 'b1',
        'clientId': 'c1',
        'clientInfo': {'name': 'Cliente'},
        'docNumber': 'F-001',
        'saleItems': [
          {
            'product': {'id': 'p1', 'name': 'Prod', 'unitName': 'UND'},
            'selectedPrice': 1,
            'quantity': 1,
            'cost': 500,
            'price': 10000,
            'subTotal': 10000,
            'discountPercentage': 10,
            'totalDiscount': 1000,
            'total': 9000,
          },
        ],
        'status': 'paid',
        'paymentType': 'cash',
        'discountType': 'percentage',
        'discountValue': 20,
        'itemDiscounts': 1000,
        'invoiceDiscount': 1800,
        'totalCost': 500,
        'total': 7200,
        'createdAt': DateTime(2026).millisecondsSinceEpoch,
        'createdBy': {'id': 'u1', 'name': 'User'},
      });

      expect(inv.discountType, DiscountType.percentage);
      expect(inv.discountValue, 20);
      expect(inv.effectiveItemDiscounts, 1000);
      expect(inv.invoiceDiscount, 1800);
      expect(inv.totalDiscount, 2800);
      expect(inv.itemsSubTotal, 10000);
    });
  });

  group('CommercialProductResult discounts', () {
    test('supports predefined, manual percentage and manual amount discounts', () {
      final result = CommercialProductResult(product: _buildProduct())
        ..quantity = 2; // subTotal = 20000

      // Predefined 10%
      result.applyPredefinedDiscount(result.product.saleProfile.discounts.first);
      expect(result.effectiveDiscountType, DiscountType.percentage);
      expect(result.discountPercent, 10);
      expect(result.totalDiscount, 2000);
      expect(result.total, 18000);

      // Manual amount 3500
      result.applyManualDiscount(DiscountType.amount, 3500);
      expect(result.effectiveDiscountType, DiscountType.amount);
      expect(result.discountPercent, 0);
      expect(result.totalDiscount, 3500);
      expect(result.total, 16500);

      // Manual percentage 25%
      result.applyManualDiscount(DiscountType.percentage, 25);
      expect(result.effectiveDiscountType, DiscountType.percentage);
      expect(result.discountPercent, 25);
      expect(result.totalDiscount, 5000);
      expect(result.total, 15000);

      // Changing price clears discount
      result.newPrice = 12000;
      expect(result.totalDiscount, 0);
      expect(result.total, 24000);
    });
  });

  group('DiscountsGateFilter', () {
    testWidgets('hides child when useDiscounts is false and shows when true', (tester) async {
      final settingsCubit = AppSettingsCubit(_FakeAppSettingsRepository());
      settingsCubit.emit(
        AppSettingsLoaded(
          const AppSettingModel(
            id: 'Default',
            createdAt: 0,
            useDiscounts: false,
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Gate(
              filters: [DiscountsGateFilter(appSettingsCubit: settingsCubit)],
              child: const Text('Descuentos activos'),
            ),
          ),
        ),
      );

      expect(find.text('Descuentos activos'), findsNothing);

      settingsCubit.emit(
        AppSettingsLoaded(
          const AppSettingModel(
            id: 'Default',
            createdAt: 0,
            useDiscounts: true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Descuentos activos'), findsOneWidget);
      await settingsCubit.close();
    });
  });
}
