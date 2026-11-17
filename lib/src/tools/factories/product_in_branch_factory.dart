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
    productType: product.productType,
    branchId: product.branchId,
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
    final convertedToNonInventory = tracksInventory && !product.tracksInventory;
    final nextAccount = convertedToNonInventory
        ? ProductAccountInDb(
            productId: account.productId,
            branchId: account.branchId,
            currentStock: 0,
            promiseStock: 0,
            averageCost: 0,
            lastCost: 0,
            maximumCost: 0,
            createdAt: account.createdAt,
            updatedAt: DateTime.now(),
          )
        : account;

    return productInBranchFromProduct(
      product: product,
      account: nextAccount,
      saleProfile: saleProfile,
    );
  }
}
