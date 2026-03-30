class InitBalanceItem {
  final int initialBalance;
  final String productName;

  InitBalanceItem({
    required this.initialBalance,
    this.productName = "SALDO INICIAL",
  });

  Map<String, dynamic> toJson() {
    return {
      'initialBalance': initialBalance,
      'productName': productName,
    };
  }

  factory InitBalanceItem.fromJson(Map<String, dynamic> json) {
    return InitBalanceItem(
      initialBalance: json['initialBalance'] as int,
      productName: json['productName'] as String? ?? "SALDO INICIAL",
    );
  }
}

class CreateMultipleInitialBalance {
  final String branchId;
  final String clientId;
  final List<InitBalanceItem> initialBalances;

  CreateMultipleInitialBalance({
    required this.branchId,
    required this.clientId,
    required this.initialBalances,
  });

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'clientId': clientId,
      'initialBalances': initialBalances.map((e) => e.toJson()).toList(),
    };
  }
}
