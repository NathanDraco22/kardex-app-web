import 'package:kardex_business/src/domain/models/client/client_model.dart';
import 'package:kardex_business/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_business/src/domain/models/common/user_info.dart';
import 'package:kardex_business/src/domain/models/product/product_model.dart';
import 'package:kardex_business/src/domain/models/product_sale_profile/product_sale_profile_model.dart';

class HoldSaleItem {
  final ProductInDbInBranch product;
  final int newPrice;
  final int selectedPriceLevel;
  final int quantity;
  final int selectedUnitIndex;
  final int conversionFactor;
  final String selectedUnitName;
  final Discount? selectedDiscount;

  HoldSaleItem({
    required this.product,
    required this.newPrice,
    this.selectedPriceLevel = 1,
    required this.quantity,
    this.selectedUnitIndex = 0,
    this.conversionFactor = 1,
    this.selectedUnitName = '',
    this.selectedDiscount,
  });

  factory HoldSaleItem.fromJson(Map<String, dynamic> json) {
    return HoldSaleItem(
      product: ProductInDbInBranch.fromJson(json['product'] as Map<String, dynamic>),
      newPrice: json['newPrice'] as int? ?? 0,
      selectedPriceLevel: json['selectedPriceLevel'] as int? ?? 1,
      quantity: json['quantity'] as int? ?? 0,
      selectedUnitIndex: json['selectedUnitIndex'] as int? ?? 0,
      conversionFactor: json['conversionFactor'] as int? ?? 1,
      selectedUnitName: json['selectedUnitName'] as String? ?? '',
      selectedDiscount: json['selectedDiscount'] != null
          ? Discount.fromJson(json['selectedDiscount'] as Map<String, dynamic>)
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

class BaseHoldSale {
  final String branchId;
  final ClientInDb? client;
  final int selectedPriceLevel;
  final bool isWholesale;
  final String description;
  final PaymentType selectedPaymentType;
  final List<HoldSaleItem> items;
  final int totalQuantity;
  final int totalAmount;
  final UserInfo? createdBy;

  BaseHoldSale({
    required this.branchId,
    this.client,
    this.selectedPriceLevel = 1,
    this.isWholesale = false,
    this.description = '',
    this.selectedPaymentType = PaymentType.cash,
    this.items = const [],
    this.totalQuantity = 0,
    this.totalAmount = 0,
    this.createdBy,
  });
}

class CreateHoldSale extends BaseHoldSale {
  CreateHoldSale({
    required super.branchId,
    super.client,
    super.selectedPriceLevel = 1,
    super.isWholesale = false,
    super.description = '',
    super.selectedPaymentType = PaymentType.cash,
    super.items = const [],
    super.totalQuantity = 0,
    super.totalAmount = 0,
    super.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'client': client?.toJson(),
      'selectedPriceLevel': selectedPriceLevel,
      'isWholesale': isWholesale,
      'description': description,
      'selectedPaymentType': selectedPaymentType.name,
      'items': items.map((e) => e.toJson()).toList(),
      'totalQuantity': totalQuantity,
      'totalAmount': totalAmount,
      'createdBy': createdBy?.toJson(),
    };
  }
}

class UpdateHoldSale {
  final String? description;
  final ClientInDb? client;
  final int? selectedPriceLevel;
  final bool? isWholesale;
  final PaymentType? selectedPaymentType;
  final List<HoldSaleItem>? items;
  final int? totalQuantity;
  final int? totalAmount;

  UpdateHoldSale({
    this.description,
    this.client,
    this.selectedPriceLevel,
    this.isWholesale,
    this.selectedPaymentType,
    this.items,
    this.totalQuantity,
    this.totalAmount,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (description != null) map['description'] = description;
    if (client != null) map['client'] = client!.toJson();
    if (selectedPriceLevel != null) map['selectedPriceLevel'] = selectedPriceLevel;
    if (isWholesale != null) map['isWholesale'] = isWholesale;
    if (selectedPaymentType != null) map['selectedPaymentType'] = selectedPaymentType!.name;
    if (items != null) map['items'] = items!.map((e) => e.toJson()).toList();
    if (totalQuantity != null) map['totalQuantity'] = totalQuantity;
    if (totalAmount != null) map['totalAmount'] = totalAmount;
    return map;
  }
}

class HoldSaleInDb extends BaseHoldSale {
  final String id;
  final int createdAt;
  final int? updatedAt;

  HoldSaleInDb({
    required this.id,
    required super.branchId,
    super.client,
    super.selectedPriceLevel = 1,
    super.isWholesale = false,
    super.description = '',
    super.selectedPaymentType = PaymentType.cash,
    super.items = const [],
    super.totalQuantity = 0,
    super.totalAmount = 0,
    super.createdBy,
    required this.createdAt,
    this.updatedAt,
  });

  DateTime get savedAt => DateTime.fromMillisecondsSinceEpoch(createdAt);

  int get computedTotalAmount {
    if (totalAmount > 0) return totalAmount;
    return items.fold<int>(0, (sum, i) {
      final subTotal = i.quantity * i.newPrice * i.conversionFactor;
      final discountPercent = i.selectedDiscount?.percentValue ?? 0;
      final discount = (subTotal * (discountPercent / 100)).round();
      return sum + (subTotal - discount);
    });
  }

  int get computedTotalQuantity {
    if (totalQuantity > 0) return totalQuantity;
    return items.fold<int>(0, (sum, i) => sum + i.quantity);
  }

  factory HoldSaleInDb.fromJson(Map<String, dynamic> json) {
    final clientJson = json['client'] as Map<String, dynamic>?;
    final createdByJson = json['createdBy'] as Map<String, dynamic>?;
    final itemsJson = json['items'] as List?;

    return HoldSaleInDb(
      id: json['id'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      client: clientJson != null ? ClientInDb.fromJson(clientJson) : null,
      selectedPriceLevel: json['selectedPriceLevel'] as int? ?? 1,
      isWholesale: json['isWholesale'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      selectedPaymentType: PaymentType.values.firstWhere(
        (e) => e.name == json['selectedPaymentType'],
        orElse: () => PaymentType.cash,
      ),
      items: itemsJson != null
          ? itemsJson
              .map((i) => HoldSaleItem.fromJson(i as Map<String, dynamic>))
              .toList()
          : [],
      totalQuantity: json['totalQuantity'] as int? ?? 0,
      totalAmount: json['totalAmount'] as int? ?? 0,
      createdBy: createdByJson != null ? UserInfo.fromJson(createdByJson) : null,
      createdAt: json['createdAt'] as int? ?? 0,
      updatedAt: json['updatedAt'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branchId': branchId,
      'client': client?.toJson(),
      'selectedPriceLevel': selectedPriceLevel,
      'isWholesale': isWholesale,
      'description': description,
      'selectedPaymentType': selectedPaymentType.name,
      'items': items.map((e) => e.toJson()).toList(),
      'totalQuantity': totalQuantity,
      'totalAmount': totalAmount,
      'createdBy': createdBy?.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
