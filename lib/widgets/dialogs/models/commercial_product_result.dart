import 'package:kardex_app_front/src/domain/models/models.dart';
import 'package:kardex_app_front/src/domain/models/product_sale_profile/product_sale_profile_model.dart';

class CommercialProductResult {
  ProductInDbInBranch product;
  Discount? selectedDisocunt;
  int quantity = 0;
  int get subTotal {
    return quantity * product.saleProfile.salePrice;
  }

  int get discountPercent => selectedDisocunt?.percentValue ?? 0;

  int get totalDiscount {
    final decimalResult = subTotal * ((selectedDisocunt?.percentValue ?? 0) / 100);
    return decimalResult.round();
  }

  int get total {
    return subTotal - totalDiscount;
  }

  CommercialProductResult({
    required this.product,
  });
}
