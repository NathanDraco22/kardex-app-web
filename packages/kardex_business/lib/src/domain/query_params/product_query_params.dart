import 'package:kardex_business/src/domain/models/product/product_type.dart';

class ProductQueryParams {
  final int offset;
  final int limit;
  final String? branchId;
  final ProductType? productType;
  final bool? onlyInventory;

  ProductQueryParams({
    required this.offset,
    required this.limit,
    this.branchId,
    this.productType,
    this.onlyInventory,
  });

  Map<String, String> toQueryParameters() {
    return {
      "offset": offset.toString(),
      "limit": limit.toString(),
      "branchId": ?branchId,
      if (productType != null) "productType": productType!.apiValue,
      if (onlyInventory != null) "onlyInventory": onlyInventory.toString(),
    };
  }
}
