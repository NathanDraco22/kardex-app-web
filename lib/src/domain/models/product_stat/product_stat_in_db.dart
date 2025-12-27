import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/src/domain/models/product_account/product_account.dart';

class ProductStatInDb {
  final String productId;
  final String branchId;
  final int startDate;
  final int endDate;
  final int totalUnits;
  final int totalTransactions;
  final int daysAnalyzed;
  final int lastEstimation;
  final int estimationLevel;

  double get unitsPerDay => totalUnits / daysAnalyzed;
  double get frecuency => totalTransactions / daysAnalyzed;

  ProductStatInDb({
    required this.productId,
    required this.branchId,
    required this.startDate,
    required this.endDate,
    required this.totalUnits,
    required this.totalTransactions,
    required this.daysAnalyzed,
    required this.lastEstimation,
    this.estimationLevel = 1,
  });

  factory ProductStatInDb.fromJson(Map<String, dynamic> json) {
    return ProductStatInDb(
      productId: json['productId'],
      branchId: json['branchId'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      totalUnits: json['totalUnits'],
      totalTransactions: json['totalTransactions'],
      daysAnalyzed: json['daysAnalyzed'],
      lastEstimation: json['lastEstimation'],
      estimationLevel: json['estimationLevel'] ?? 1,
    );
  }
}

class ProductStatInDbWithInfo extends ProductStatInDb {
  final ProductItem product;

  ProductStatInDbWithInfo({
    required super.productId,
    required super.branchId,
    required super.startDate,
    required super.endDate,
    required super.totalUnits,
    required super.totalTransactions,
    required super.daysAnalyzed,
    required super.lastEstimation,
    super.estimationLevel,
    required this.product,
  });

  factory ProductStatInDbWithInfo.fromJson(Map<String, dynamic> json) {
    return ProductStatInDbWithInfo(
      productId: json['productId'],
      branchId: json['branchId'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      totalUnits: json['totalUnits'],
      totalTransactions: json['totalTransactions'],
      daysAnalyzed: json['daysAnalyzed'],
      lastEstimation: json['lastEstimation'],
      estimationLevel: json['estimationLevel'] ?? 1,
      product: ProductItem.fromJson(json['product']),
    );
  }
}

class ProductStatInDbWithAccount extends ProductStatInDbWithInfo {
  final ProductAccountInDb account;

  ProductStatInDbWithAccount({
    required super.productId,
    required super.branchId,
    required super.startDate,
    required super.endDate,
    required super.totalUnits,
    required super.totalTransactions,
    required super.daysAnalyzed,
    required super.lastEstimation,
    super.estimationLevel,
    required super.product,
    required this.account,
  });

  factory ProductStatInDbWithAccount.fromJson(Map<String, dynamic> json) {
    return ProductStatInDbWithAccount(
      productId: json['productId'],
      branchId: json['branchId'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      totalUnits: json['totalUnits'],
      totalTransactions: json['totalTransactions'],
      daysAnalyzed: json['daysAnalyzed'],
      lastEstimation: json['lastEstimation'],
      estimationLevel: json['estimationLevel'] ?? 1,
      product: ProductItem.fromJson(json['product']),
      account: ProductAccountInDb.fromJson(json['account']),
    );
  }
}
