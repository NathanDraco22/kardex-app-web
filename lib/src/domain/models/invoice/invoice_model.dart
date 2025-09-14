enum InvoiceStatus { open, paid, parciallyPaid, cancelled }

enum PaymentType { cash, credit }

class ProductItem {
  final String id;
  final String name;
  final String unitName;
  final String brandName;
  final String? code;
  final String? categoryName;
  final List<String> tags;

  ProductItem({
    required this.id,
    required this.name,
    required this.unitName,
    required this.brandName,
    this.code,
    this.categoryName,
    this.tags = const [],
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) => ProductItem(
    id: json['id'],
    name: json['name'],
    unitName: json['unitName'],
    brandName: json['brandName'],
    code: json['code'],
    categoryName: json['categoryName'],
    tags: List<String>.from(json['tags'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'unitName': unitName,
    'brandName': brandName,
    'code': code,
    'categoryName': categoryName,
    'tags': tags,
  };
}

class SaleItem {
  final ProductItem product;
  final int quantity;
  final int bonQuantity;
  final int cost;
  final int price;
  final int subTotal;
  final int discount;
  final int total;

  SaleItem({
    required this.product,
    required this.quantity,
    this.bonQuantity = 0,
    required this.cost,
    required this.price,
    required this.subTotal,
    this.discount = 0,
    required this.total,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) => SaleItem(
    product: ProductItem.fromJson(json['product']),
    quantity: json['quantity'],
    bonQuantity: json['bonQuantity'] ?? 0,
    cost: json['cost'],
    price: json['price'],
    subTotal: json['subTotal'],
    discount: json['discount'] ?? 0,
    total: json['total'],
  );

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
    'bonQuantity': bonQuantity,
    'cost': cost,
    'price': price,
    'subTotal': subTotal,
    'discount': discount,
    'total': total,
  };
}

// --- Modelos Principales de Factura ---
class BaseInvoice {
  final String branchId;
  final String clientId;
  final String docNumber;
  final List<SaleItem> saleItems;
  final String description;
  final int amountPaid;
  final InvoiceStatus status;
  final PaymentType paymentType;
  final int totalCost;
  final int total;

  BaseInvoice({
    required this.branchId,
    required this.clientId,
    required this.docNumber,
    required this.saleItems,
    this.description = "",
    this.amountPaid = 0,
    required this.status,
    required this.paymentType,
    required this.totalCost,
    required this.total,
  });

  factory BaseInvoice.fromJson(Map<String, dynamic> json) => BaseInvoice(
    branchId: json['branchId'],
    clientId: json['clientId'],
    docNumber: json['docNumber'],
    saleItems: (json['saleItems'] as List).map((e) => SaleItem.fromJson(e)).toList(),
    description: json['description'] ?? "",
    amountPaid: json['amountPaid'] ?? 0,
    status: InvoiceStatus.values.byName(json['status'].toString().toLowerCase()),
    paymentType: PaymentType.values.byName(json['paymentType'].toString().toLowerCase()),
    totalCost: json['totalCost'],
    total: json['total'],
  );

  Map<String, dynamic> toJson() => {
    'branchId': branchId,
    'clientId': clientId,
    'docNumber': docNumber,
    'saleItems': saleItems.map((e) => e.toJson()).toList(),
    'description': description,
    'amountPaid': amountPaid,
    'status': status.name,
    'paymentType': paymentType.name,
    'totalCost': totalCost,
    'total': total,
  };
}

class CreateInvoice extends BaseInvoice {
  CreateInvoice({
    required super.branchId,
    required super.clientId,
    required super.docNumber,
    required super.saleItems,
    super.description,
    super.amountPaid,
    required super.status,
    required super.paymentType,
    required super.totalCost,
    required super.total,
  });

  factory CreateInvoice.fromJson(Map<String, dynamic> json) => CreateInvoice(
    branchId: json['branchId'],
    clientId: json['clientId'],
    docNumber: json['docNumber'],
    saleItems: (json['saleItems'] as List).map((e) => SaleItem.fromJson(e)).toList(),
    description: json['description'] ?? "",
    amountPaid: json['amountPaid'] ?? 0,
    status: InvoiceStatus.values.byName(json['status'].toString().toLowerCase()),
    paymentType: PaymentType.values.byName(json['paymentType'].toString().toLowerCase()),
    totalCost: json['totalCost'],
    total: json['total'],
  );
}

class UpdateInvoice {
  final int? ammountPaid;
  final InvoiceStatus? status;

  UpdateInvoice({this.ammountPaid, this.status});

  Map<String, dynamic> toJson() {
    final data = {
      'ammountPaid': ammountPaid,
      'status': status?.name,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

class InvoiceInDb extends BaseInvoice {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  InvoiceInDb({
    required this.id,
    required super.branchId,
    required super.clientId,
    required super.docNumber,
    required super.saleItems,
    super.description,
    super.amountPaid,
    required super.status,
    required super.paymentType,
    required super.totalCost,
    required super.total,
    required this.createdAt,
    this.updatedAt,
  });

  factory InvoiceInDb.fromJson(Map<String, dynamic> json) => InvoiceInDb(
    id: json['id'],
    branchId: json['branchId'],
    clientId: json['clientId'],
    docNumber: json['docNumber'],
    saleItems: (json['saleItems'] as List).map((e) => SaleItem.fromJson(e)).toList(),
    description: json['description'] ?? "",
    amountPaid: json['amountPaid'] ?? 0,
    status: InvoiceStatus.values.byName(json['status'].toString().toLowerCase()),
    paymentType: PaymentType.values.byName(json['paymentType'].toString().toLowerCase()),
    totalCost: json['totalCost'],
    total: json['total'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
  );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    });
    return data;
  }
}
