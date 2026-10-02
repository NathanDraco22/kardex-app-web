import 'package:kardex_business/kardex_business.dart';

ProductInDbInBranch productInBranchFromProduct({
  required ProductInDb product,
  required ProductAccountInDb account,
  required ProductSaleProfileInDb saleProfile,
}) {
  return ProductInDbInBranch(
    id: product.id,
    name: product.name,
    description: product.description,
    code: product.code,
    altCode: product.altCode,
    image: product.image,
    brandName: product.brandName,
    unitName: product.unitName,
    categoryName: product.categoryName,
    tags: product.tags,
    hasIva: product.hasIva,
    isActive: product.isActive,
    extraUnits: product.extraUnits,
    defaultUnitIndex: product.defaultUnitIndex,
    wholesaleUnitIndex: product.wholesaleUnitIndex,
    isDeleted: product.isDeleted,
    createdAt: product.createdAt,
    updatedAt: product.updatedAt,
    account: account,
    saleProfile: saleProfile,
  );
}

extension ProductInDbInBranchUpdateX on ProductInDbInBranch {
  ProductInDbInBranch updateWithProduct(ProductInDb product) {
    return productInBranchFromProduct(
      product: product,
      account: account,
      saleProfile: saleProfile,
    );
  }
}
