import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/modules/commercial/anon_invoices/view_controller.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_business/kardex_business.dart';

ProductInDbInBranch _simpleProduct({int salePrice = 1012}) {
  final now = DateTime(2026, 11, 27);
  return ProductInDbInBranch(
    id: 'p1',
    name: 'Producto 1',
    unitName: 'UND',
    categoryName: 'General',
    tags: const [],
    hasIva: false,
    extraUnits: const [],
    defaultUnitIndex: 0,
    wholesaleUnitIndex: 0,
    priceUnitFactor: 1,
    createdAt: now,
    account: ProductAccountInDb(
      branchId: 'b1',
      productId: 'p1',
      currentStock: 10,
      averageCost: 500,
      lastCost: 500,
      maximumCost: 500,
      createdAt: now,
    ),
    saleProfile: ProductSaleProfileInDb(
      branchId: 'b1',
      productId: 'p1',
      salePrice: salePrice,
      salePrice2: salePrice,
      salePrice3: salePrice,
      salePrice4: salePrice,
    ),
  );
}

SaleItem _item({
  int price = 1012,
  int quantity = 1,
  int totalDiscount = 0,
}) {
  return SaleItem(
    product: ProductItem(id: 'p1', name: 'Producto 1', unitName: 'UND'),
    selectedPrice: 1,
    quantity: quantity,
    cost: 500,
    price: price,
    subTotal: price * quantity,
    totalDiscount: totalDiscount,
    total: (price * quantity) - totalDiscount,
  );
}

CreateInvoice _invoice(List<SaleItem> items) {
  return CreateInvoice(
    branchId: 'b1',
    clientId: 'c1',
    clientInfo: ClientInfo(name: 'Cliente', group: ''),
    docNumber: 'F-1',
    saleItems: items,
    status: InvoiceStatus.paid,
    paymentType: PaymentType.cash,
    bankReference: '',
    totalCost: 500,
    total: 0,
    createdBy: const UserInfo(id: 'u1', name: 'User'),
  );
}

void main() {
  tearDown(() {
    InvoiceRounding.configureEnabledResolver(null);
  });

  test('roundUpToWholeUnit sube al siguiente entero de la moneda', () {
    expect(InvoiceRounding.roundUpToWholeUnit(0), 0);
    expect(InvoiceRounding.roundUpToWholeUnit(1), 100);
    expect(InvoiceRounding.roundUpToWholeUnit(1012), 1100);
    expect(InvoiceRounding.roundUpToWholeUnit(1100), 1100);
  });

  test('roundDownToWholeUnit baja al entero anterior de la moneda', () {
    expect(InvoiceRounding.roundDownToWholeUnit(0), 0);
    expect(InvoiceRounding.roundDownToWholeUnit(99), 0);
    expect(InvoiceRounding.roundDownToWholeUnit(1012), 1000);
    expect(InvoiceRounding.roundDownToWholeUnit(1100), 1100);
  });

  test('ensureCostAndTotal redondea subtotal hacia arriba y total entero', () {
    InvoiceRounding.configureEnabledResolver(() => true);
    final invoice = _invoice([_item()]);

    invoice.ensureCostAndTotal();

    expect(invoice.itemDiscounts, 0);
    expect(invoice.invoiceDiscount, 0);
    expect(invoice.total, 1100);
  });

  test('ensureCostAndTotal redondea descuentos hacia abajo', () {
    InvoiceRounding.configureEnabledResolver(() => true);
    final invoice = _invoice([_item(totalDiscount: 101)]);

    invoice.ensureCostAndTotal();

    expect(invoice.itemDiscounts, 100);
    expect(invoice.total, 1000);
  });

  test('ensureCostAndTotal recalcula el descuento de línea sobre el subtotal redondeado', () {
    InvoiceRounding.configureEnabledResolver(() => true);
    final item = SaleItem(
      product: ProductItem(id: 'p1', name: 'Producto 1', unitName: 'UND'),
      selectedPrice: 1,
      quantity: 1,
      cost: 500,
      price: 101,
      subTotal: 101,
      discountType: DiscountType.percentage,
      discountPercentage: 50,
      totalDiscount: 51,
      total: 50,
    );
    final invoice = _invoice([item]);

    invoice.ensureCostAndTotal();

    // Subtotal 1.01 -> 2.00; 50% de 2.00 = 1.00; total = 1.00
    expect(invoice.itemDiscounts, 100);
    expect(invoice.total, 100);
  });

  test('ensureCostAndTotal no redondea cuando la opción está apagada', () {
    InvoiceRounding.configureEnabledResolver(() => false);
    final invoice = _invoice([_item(totalDiscount: 101)]);

    invoice.ensureCostAndTotal();

    expect(invoice.itemDiscounts, 101);
    expect(invoice.total, 911);
  });

  test('ensureCostAndTotal respeta applyRounding=false', () {
    InvoiceRounding.configureEnabledResolver(() => true);
    final invoice = _invoice([_item(totalDiscount: 101)]);

    invoice.ensureCostAndTotal(applyRounding: false);

    expect(invoice.itemDiscounts, 101);
    expect(invoice.total, 911);
  });

  test('projectedInvoiceTotal conserva el fallback cuando está apagado', () {
    InvoiceRounding.configureEnabledResolver(() => false);
    expect(
      InvoiceRounding.projectedInvoiceTotal(
        fallbackTotal: 1234,
        items: [_item()],
      ),
      1234,
    );
  });

  test('projectedInvoiceTotal redondea cuando está activo', () {
    InvoiceRounding.configureEnabledResolver(() => true);
    expect(
      InvoiceRounding.projectedInvoiceTotal(
        fallbackTotal: 1012,
        items: [_item()],
      ),
      1100,
    );
  });

  test('calculateInvoiceTotal redondea el descuento global de factura anónima', () {
    InvoiceRounding.configureEnabledResolver(() => true);
    expect(
      InvoiceRounding.calculateInvoiceTotal(
        items: [_item()],
        discountType: DiscountType.percentage,
        discountValue: 15,
      ),
      1000,
    );
  });

  test('AppSettingModel y UpdateAppSetting soportan roundUpInvoiceTotals', () {
    const settings = AppSettingModel(id: 'Default', createdAt: 0);
    expect(settings.roundUpInvoiceTotals, isFalse);

    final enabled = AppSettingModel.fromJson({
      'id': 'Default',
      'createdAt': 0,
      'roundUpInvoiceTotals': true,
    });
    expect(enabled.roundUpInvoiceTotals, isTrue);
    expect(
      const UpdateAppSetting(roundUpInvoiceTotals: true).toJson(),
      {'roundUpInvoiceTotals': true},
    );
  });

  test('AnonInvoiceViewController usa el total redondeado con descuento global', () {
    InvoiceRounding.configureEnabledResolver(() => true);
    final controller = AnonInvoiceViewController();
    final item = CommercialProductResult(product: _simpleProduct());
    item.quantity = 1;
    controller.addItem(item);

    expect(controller.itemsSubTotal, 1100);

    controller.setInvoiceDiscount(DiscountType.percentage, 15);

    // 15% de 11.00 = 1.65 -> 1.00; total = 10.00
    expect(controller.invoiceDiscountAmount, 100);
    expect(controller.totalAmount, 1000);
  });
}
