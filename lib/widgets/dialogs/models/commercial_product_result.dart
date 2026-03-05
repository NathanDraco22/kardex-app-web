import 'package:kardex_app_front/src/domain/models/models.dart';
import 'package:kardex_app_front/src/domain/models/product_sale_profile/product_sale_profile_model.dart';

class CommercialProductResult {
  CommercialProductResult({
    required this.product,
  }) {
    _newPrice = product.saleProfile.salePrice;
  }
  ProductInDbInBranch product;
  int _newPrice = 0;
  int selectedPriceLevel = 1;
  Discount? selectedDisocunt;
  int quantity = 0;
  int get subTotal {
    return quantity * _newPrice;
  }

  int get newPrice => _newPrice;

  set newPrice(int value) {
    selectedDisocunt = null;
    _newPrice = value;
  }

  int get discountPercent => selectedDisocunt?.percentValue ?? 0;

  int get totalDiscount {
    final decimalResult = subTotal * ((selectedDisocunt?.percentValue ?? 0) / 100);
    return decimalResult.round();
  }

  int get total {
    return subTotal - totalDiscount;
  }

  CommercialProductResult copyWith({
    ProductInDbInBranch? product,
    int? newPrice,
    int? selectedPriceLevel,
    Discount? selectedDisocunt,
    int? quantity,
  }) {
    final result = CommercialProductResult(
      product: product ?? this.product,
    );

    if (newPrice != null) {
      result.newPrice = newPrice;
    } else {
      result._newPrice = _newPrice;
    }

    result.selectedPriceLevel = selectedPriceLevel ?? this.selectedPriceLevel;

    if (selectedDisocunt != null) {
      result.selectedDisocunt = selectedDisocunt;
    } else if (newPrice == null) {
      result.selectedDisocunt = this.selectedDisocunt;
    }

    result.quantity = quantity ?? this.quantity;

    return result;
  }
}
