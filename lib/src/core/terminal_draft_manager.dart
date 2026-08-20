import 'dart:convert';

import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_business/kardex_business.dart';

class SaleTerminalItemDraft {
  final ProductInDbInBranch product;
  final int newPrice;
  final int selectedPriceLevel;
  final int quantity;
  final int selectedUnitIndex;
  final int conversionFactor;
  final String selectedUnitName;
  final Discount? selectedDiscount;

  SaleTerminalItemDraft({
    required this.product,
    required this.newPrice,
    required this.selectedPriceLevel,
    required this.quantity,
    required this.selectedUnitIndex,
    required this.conversionFactor,
    required this.selectedUnitName,
    this.selectedDiscount,
  });

  factory SaleTerminalItemDraft.fromCommercialProductResult(CommercialProductResult item) {
    return SaleTerminalItemDraft(
      product: item.product,
      newPrice: item.newPrice,
      selectedPriceLevel: item.selectedPriceLevel,
      quantity: item.quantity,
      selectedUnitIndex: item.selectedUnitIndex,
      conversionFactor: item.conversionFactor,
      selectedUnitName: item.selectedUnitName,
      selectedDiscount: item.selectedDiscount,
    );
  }

  CommercialProductResult toCommercialProductResult() {
    final result = CommercialProductResult(
      product: product,
      defaultPriceLevel: selectedPriceLevel,
    );
    result.newPrice = newPrice;
    result.selectedPriceLevel = selectedPriceLevel;
    result.quantity = quantity;
    result.selectedUnitIndex = selectedUnitIndex;
    result.conversionFactor = conversionFactor;
    result.selectedUnitName = selectedUnitName;
    result.selectedDiscount = selectedDiscount;
    return result;
  }

  factory SaleTerminalItemDraft.fromJson(Map<String, dynamic> json) {
    return SaleTerminalItemDraft(
      product: ProductInDbInBranch.fromJson(json['product']),
      newPrice: json['newPrice'] as int? ?? 0,
      selectedPriceLevel: json['selectedPriceLevel'] as int? ?? 1,
      quantity: json['quantity'] as int? ?? 0,
      selectedUnitIndex: json['selectedUnitIndex'] as int? ?? 0,
      conversionFactor: json['conversionFactor'] as int? ?? 1,
      selectedUnitName: json['selectedUnitName'] as String? ?? '',
      selectedDiscount: json['selectedDiscount'] != null
          ? Discount.fromJson(json['selectedDiscount'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'newPrice': newPrice,
      'selectedPriceLevel': selectedPriceLevel,
      'quantity': quantity,
      'selectedUnitIndex': selectedUnitIndex,
      'conversionFactor': conversionFactor,
      'selectedUnitName': selectedUnitName,
      'selectedDiscount': selectedDiscount?.toJson(),
    };
  }
}

class SaleTerminalDraft {
  final String id;
  final DateTime savedAt;
  final ClientInDb? client;
  final int selectedPriceLevel;
  final bool isWholesale;
  final String description;
  final PaymentType selectedPaymentType;
  final List<SaleTerminalItemDraft> items;

  SaleTerminalDraft({
    required this.id,
    required this.savedAt,
    this.client,
    this.selectedPriceLevel = 1,
    this.isWholesale = false,
    this.description = '',
    this.selectedPaymentType = PaymentType.cash,
    this.items = const [],
  });

  int get totalQuantity => items.fold<int>(0, (sum, i) => sum + i.quantity);

  int get totalAmount => items.fold<int>(0, (sum, i) {
        final subTotal = i.quantity * i.newPrice * i.conversionFactor;
        final discountPercent = i.selectedDiscount?.percentValue ?? 0;
        final discount = (subTotal * (discountPercent / 100)).round();
        return sum + (subTotal - discount);
      });

  factory SaleTerminalDraft.fromJson(Map<String, dynamic> json) {
    final clientJson = json['client'];
    final itemsJson = json['items'] as List?;
    return SaleTerminalDraft(
      id: json['id'] as String? ?? '',
      savedAt: DateTime.tryParse(json['savedAt'] as String? ?? '') ?? DateTime.now(),
      client: clientJson != null ? ClientInDb.fromJson(clientJson) : null,
      selectedPriceLevel: json['selectedPriceLevel'] as int? ?? 1,
      isWholesale: json['isWholesale'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      selectedPaymentType: PaymentType.values.firstWhere(
        (e) => e.name == json['selectedPaymentType'],
        orElse: () => PaymentType.cash,
      ),
      items: itemsJson != null
          ? itemsJson.map((i) => SaleTerminalItemDraft.fromJson(i as Map<String, dynamic>)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'savedAt': savedAt.toIso8601String(),
      'client': client?.toJson(),
      'selectedPriceLevel': selectedPriceLevel,
      'isWholesale': isWholesale,
      'description': description,
      'selectedPaymentType': selectedPaymentType.name,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

class SaleTerminalDraftManager with HiveService {
  final _boxName = 'saleTerminalDraftsBox';

  static final SaleTerminalDraftManager _instance = SaleTerminalDraftManager._internal();
  factory SaleTerminalDraftManager() => _instance;
  SaleTerminalDraftManager._internal();

  /// Retorna todas las ventas en espera guardadas para la sucursal,
  /// ordenadas de más reciente a más antigua.
  Future<List<SaleTerminalDraft>> getDrafts(String branchId) async {
    final box = await getBox(_boxName);
    final raw = box.get(branchId);
    if (raw == null) return [];

    try {
      final List<dynamic> listJson = json.decode(raw);
      final drafts = listJson
          .map((item) => SaleTerminalDraft.fromJson(item as Map<String, dynamic>))
          .toList();
      drafts.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      return drafts;
    } catch (_) {
      return [];
    }
  }

  /// Guarda una nueva venta en espera para la sucursal.
  Future<void> saveDraft(String branchId, SaleTerminalDraft draft) async {
    final drafts = await getDrafts(branchId);
    drafts.removeWhere((d) => d.id == draft.id);
    drafts.insert(0, draft);

    final box = await getBox(_boxName);
    final data = json.encode(drafts.map((d) => d.toJson()).toList());
    await box.put(branchId, data);
  }

  /// Elimina una venta en espera por su id.
  Future<void> removeDraft(String branchId, String draftId) async {
    final drafts = await getDrafts(branchId);
    drafts.removeWhere((d) => d.id == draftId);

    final box = await getBox(_boxName);
    if (drafts.isEmpty) {
      await box.delete(branchId);
    } else {
      final data = json.encode(drafts.map((d) => d.toJson()).toList());
      await box.put(branchId, data);
    }
  }

  /// Elimina todas las ventas en espera de la sucursal.
  Future<void> clearAllDrafts(String branchId) async {
    final box = await getBox(_boxName);
    await box.delete(branchId);
  }

  /// Retorna la cantidad de ventas en espera.
  Future<int> countDrafts(String branchId) async {
    final drafts = await getDrafts(branchId);
    return drafts.length;
  }
}
