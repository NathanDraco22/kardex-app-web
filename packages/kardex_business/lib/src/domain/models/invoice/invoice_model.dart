import 'package:kardex_business/src/domain/models/common/client_info.dart';
import 'package:kardex_business/src/domain/models/common/discount_type.dart';
import 'package:kardex_business/src/domain/models/common/order_info.dart';
import 'package:kardex_business/src/domain/models/common/payment_detail.dart';
import 'package:kardex_business/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_business/src/domain/models/common/user_info.dart';
import 'package:kardex_business/src/tools/invoice_rounding.dart';
import 'package:kardex_business/src/tools/unit_conversion_tool.dart';

enum InvoiceStatus { draft, open, paid, partiallypaid, cancelled }

class InvoiceDisplayConfig {
  const InvoiceDisplayConfig({
    this.showItemsSummary = false,
    this.showOrderCreator = false,
  });

  final bool showItemsSummary;
  final bool showOrderCreator;
}

typedef InvoiceDisplayConfigResolver = InvoiceDisplayConfig Function();

class BaseInvoice {
  static InvoiceDisplayConfigResolver? _displayConfigResolver;

  static void configureDisplayConfigResolver(
    InvoiceDisplayConfigResolver? resolver,
  ) {
    _displayConfigResolver = resolver;
  }

  static InvoiceDisplayConfig get displayConfig =>
      _displayConfigResolver?.call() ?? const InvoiceDisplayConfig();
  final String branchId;
  final String clientId;
  final ClientInfo clientInfo;
  final String docNumber;
  final String orderNumber;
  final OrderInfo? orderInfo;
  final List<SaleItem> saleItems;
  final String description;
  final int amountPaid;
  final InvoiceStatus status;
  final PaymentType paymentType;
  final String bankReference;
  final PaymentDetail? paymentDetail;
  final DiscountType? discountType;
  final int discountValue;
  int itemDiscounts;
  int invoiceDiscount;
  int totalCost;
  int total;
  final DateTime? paidAt;
  final UserInfo createdBy;
  final UserInfo? invoicedBy;
  final String? shiftId;
  final DateTime? cancelledAt;
  final UserInfo? cancelledBy;
  final String? cancellationReason;
  final String? cancellationRequestId;

  BaseInvoice({
    required this.branchId,
    required this.clientId,
    required this.clientInfo,
    required this.docNumber,
    this.orderNumber = "",
    this.orderInfo,
    required this.saleItems,
    this.description = "",
    this.amountPaid = 0,
    required this.status,
    required this.paymentType,
    required this.bankReference,
    this.paymentDetail,
    this.discountType,
    this.discountValue = 0,
    this.itemDiscounts = 0,
    this.invoiceDiscount = 0,
    required this.totalCost,
    required this.total,
    this.paidAt,
    required this.createdBy,
    this.invoicedBy,
    this.shiftId,
    this.cancelledAt,
    this.cancelledBy,
    this.cancellationReason,
    this.cancellationRequestId,
  });

  bool get isCancelled => status == InvoiceStatus.cancelled;

  int get itemsSubTotal =>
      saleItems.fold<int>(0, (sum, item) => sum + item.subTotal);

  int get effectiveItemDiscounts => itemDiscounts > 0
      ? itemDiscounts
      : saleItems.fold<int>(0, (sum, item) => sum + item.totalDiscount);

  int get itemsNetTotal =>
      saleItems.fold<int>(0, (sum, item) => sum + item.total);

  int get totalDiscount => effectiveItemDiscounts + invoiceDiscount;

  int get totalRemaining => total - amountPaid;

  int get totalItemsCount => saleItems.length;

  double get totalItemsQuantity => saleItems.fold<double>(
    0.0,
    (sum, item) => sum + item.effectiveTotalDisplayQuantity,
  );

  String get formattedTotalItemsQuantity =>
      UnitConversionTool.formatQuantity(totalItemsQuantity, maxDecimals: 6);

  factory BaseInvoice.fromJson(Map<String, dynamic> json) => BaseInvoice(
    branchId: json['branchId'],
    clientId: json['clientId'],
    clientInfo: ClientInfo.fromJson(json['clientInfo']),
    docNumber: json['docNumber'] ?? "",
    orderNumber: json['orderNumber'] ?? "",
    orderInfo: json['orderInfo'] != null ? OrderInfo.fromJson(json['orderInfo']) : null,
    saleItems: (json['saleItems'] as List).map((e) => SaleItem.fromJson(e)).toList(),
    description: json['description'] ?? "",
    amountPaid: json['amountPaid'] ?? 0,
    status: InvoiceStatus.values.byName(json['status'].toString().toLowerCase()),
    paymentType: PaymentType.values.byName(json['paymentType'].toString().toLowerCase()),
    bankReference: json['bankReference'] ?? "",
    paymentDetail: json['paymentDetail'] != null
        ? PaymentDetail.fromJson(Map<String, dynamic>.from(json['paymentDetail']))
        : null,
    discountType: DiscountType.tryFromApi(json['discountType'] as String?),
    discountValue: json['discountValue'] as int? ?? 0,
    itemDiscounts: json['itemDiscounts'] as int? ?? 0,
    invoiceDiscount: json['invoiceDiscount'] as int? ?? 0,
    totalCost: json['totalCost'],
    total: json['total'],
    paidAt: json['paidAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['paidAt']) : null,
    createdBy: UserInfo.fromJson(json['createdBy']),
    invoicedBy: json['invoicedBy'] != null
        ? UserInfo.fromJson(json['invoicedBy'])
        : null,
    shiftId: json['shiftId'] as String?,
    cancelledAt: json['cancelledAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch((json['cancelledAt'] as num).toInt())
        : null,
    cancelledBy: json['cancelledBy'] != null
        ? UserInfo.fromJson(json['cancelledBy'] as Map<String, dynamic>)
        : null,
    cancellationReason: json['cancellationReason'] as String?,
    cancellationRequestId: json['cancellationRequestId'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'branchId': branchId,
    'clientId': clientId,
    'clientInfo': clientInfo.toJson(),
    'docNumber': docNumber,
    'orderNumber': orderNumber,
    if (orderInfo != null) 'orderInfo': orderInfo!.toJson(),
    'saleItems': saleItems.map((e) => e.toJson()).toList(),
    'description': description,
    'amountPaid': amountPaid,
    'status': status.name,
    'paymentType': paymentType.name,
    'bankReference': bankReference,
    if (paymentDetail != null) 'paymentDetail': paymentDetail!.toJson(),
    if (discountType != null) 'discountType': discountType!.apiValue,
    'discountValue': discountValue,
    'itemDiscounts': itemDiscounts,
    'invoiceDiscount': invoiceDiscount,
    'totalCost': totalCost,
    'total': total,
    'paidAt': paidAt?.millisecondsSinceEpoch,
    'createdBy': createdBy.toJson(),
    if (invoicedBy != null) 'invoicedBy': invoicedBy!.toJson(),
    if (shiftId != null) 'shiftId': shiftId,
    if (cancelledAt != null) 'cancelledAt': cancelledAt!.millisecondsSinceEpoch,
    if (cancelledBy != null) 'cancelledBy': cancelledBy!.toJson(),
    if (cancellationReason != null) 'cancellationReason': cancellationReason,
    if (cancellationRequestId != null) 'cancellationRequestId': cancellationRequestId,
  };
}

class CreateInvoice extends BaseInvoice {
  CreateInvoice({
    required super.branchId,
    required super.clientId,
    required super.clientInfo,
    required super.docNumber,
    super.orderNumber = "",
    super.orderInfo,
    required super.saleItems,
    super.description,
    super.amountPaid,
    required super.status,
    required super.paymentType,
    required super.bankReference,
    super.paymentDetail,
    super.discountType,
    super.discountValue = 0,
    super.itemDiscounts = 0,
    super.invoiceDiscount = 0,
    required super.totalCost,
    required super.total,
    required super.createdBy,
    super.invoicedBy,
    super.shiftId,
    super.cancelledAt,
    super.cancelledBy,
    super.cancellationReason,
    super.cancellationRequestId,
  });

  factory CreateInvoice.fromJson(Map<String, dynamic> json) => CreateInvoice(
    branchId: json['branchId'],
    clientId: json['clientId'],
    clientInfo: ClientInfo.fromJson(json['clientInfo']),
    docNumber: json['docNumber'] ?? "",
    orderNumber: json['orderNumber'] ?? "",
    orderInfo: json['orderInfo'] != null ? OrderInfo.fromJson(json['orderInfo']) : null,
    saleItems: (json['saleItems'] as List).map((e) => SaleItem.fromJson(e)).toList(),
    description: json['description'] ?? "",
    amountPaid: json['amountPaid'] ?? 0,
    status: InvoiceStatus.values.byName(json['status'].toString().toLowerCase()),
    paymentType: PaymentType.values.byName(json['paymentType'].toString().toLowerCase()),
    bankReference: json['bankReference'] ?? "",
    paymentDetail: json['paymentDetail'] != null
        ? PaymentDetail.fromJson(Map<String, dynamic>.from(json['paymentDetail']))
        : null,
    discountType: DiscountType.tryFromApi(json['discountType'] as String?),
    discountValue: json['discountValue'] as int? ?? 0,
    itemDiscounts: json['itemDiscounts'] as int? ?? 0,
    invoiceDiscount: json['invoiceDiscount'] as int? ?? 0,
    totalCost: json['totalCost'],
    total: json['total'],
    createdBy: UserInfo.fromJson(json['createdBy']),
    invoicedBy: json['invoicedBy'] != null
        ? UserInfo.fromJson(json['invoicedBy'])
        : null,
    shiftId: json['shiftId'] as String?,
    cancelledAt: json['cancelledAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch((json['cancelledAt'] as num).toInt())
        : null,
    cancelledBy: json['cancelledBy'] != null
        ? UserInfo.fromJson(json['cancelledBy'] as Map<String, dynamic>)
        : null,
    cancellationReason: json['cancellationReason'] as String?,
    cancellationRequestId: json['cancellationRequestId'] as String?,
  );

  CreateInvoice copyWithPaymentMethod(
    PaymentType paymentType,
    String? bankReference, {
    PaymentDetail? paymentDetail,
  }) {
    return CreateInvoice(
      branchId: branchId,
      clientId: clientId,
      clientInfo: clientInfo,
      docNumber: docNumber,
      orderNumber: orderNumber,
      orderInfo: orderInfo,
      saleItems: saleItems,
      description: description,
      amountPaid: amountPaid,
      status: status,
      paymentType: paymentType,
      bankReference: bankReference ?? "",
      paymentDetail: paymentDetail ?? this.paymentDetail,
      discountType: discountType,
      discountValue: discountValue,
      itemDiscounts: itemDiscounts,
      invoiceDiscount: invoiceDiscount,
      totalCost: totalCost,
      total: total,
      createdBy: createdBy,
      invoicedBy: invoicedBy,
      shiftId: shiftId,
    );
  }

  void ensureCostAndTotal({bool applyRounding = true}) {
    final shouldRound = applyRounding && InvoiceRounding.isEnabled;
    int newTotalCost = 0;
    int newItemsNet = 0;
    int newItemDiscounts = 0;
    for (var item in saleItems) {
      newTotalCost += item.lineCost;
      final subTotal = shouldRound
          ? InvoiceRounding.roundUpToWholeUnit(item.subTotal)
          : item.subTotal;
      final discount = shouldRound
          ? InvoiceRounding.roundDownToWholeUnit(
              InvoiceRounding.rawItemDiscount(item, subTotal),
            )
          : item.totalDiscount;
      newItemsNet += subTotal - discount;
      newItemDiscounts += discount;
    }
    itemDiscounts = newItemDiscounts;
    var newInvoiceDiscount = DiscountType.calculateDiscountAmount(
      type: discountType,
      discountValue: discountValue,
      baseAmount: newItemsNet,
    );
    if (shouldRound) {
      newInvoiceDiscount =
          InvoiceRounding.roundDownToWholeUnit(newInvoiceDiscount);
    }
    invoiceDiscount = newInvoiceDiscount;
    totalCost = newTotalCost;
    total = (newItemsNet - invoiceDiscount).clamp(0, newItemsNet);
  }
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
    required super.clientInfo,
    required super.docNumber,
    super.orderNumber = "",
    super.orderInfo,
    required super.saleItems,
    super.description,
    super.amountPaid,
    required super.status,
    required super.paymentType,
    required super.bankReference,
    super.paymentDetail,
    super.discountType,
    super.discountValue = 0,
    super.itemDiscounts = 0,
    super.invoiceDiscount = 0,
    required super.totalCost,
    required super.total,
    required this.createdAt,
    this.updatedAt,
    super.paidAt,
    required super.createdBy,
    super.invoicedBy,
    super.shiftId,
    super.cancelledAt,
    super.cancelledBy,
    super.cancellationReason,
    super.cancellationRequestId,
  });

  factory InvoiceInDb.fromJson(Map<String, dynamic> json) => InvoiceInDb(
    id: json['id'],
    branchId: json['branchId'],
    clientId: json['clientId'],
    clientInfo: ClientInfo.fromJson(json['clientInfo']),
    docNumber: json['docNumber'] ?? "",
    orderNumber: json['orderNumber'] ?? "",
    orderInfo: json['orderInfo'] != null ? OrderInfo.fromJson(json['orderInfo']) : null,
    saleItems: (json['saleItems'] as List).map((e) => SaleItem.fromJson(e)).toList(),
    description: json['description'] ?? "",
    amountPaid: json['amountPaid'] ?? 0,
    status: InvoiceStatus.values.byName(json['status'].toString().toLowerCase()),
    paymentType: PaymentType.values.byName(json['paymentType'].toString().toLowerCase()),
    bankReference: json['bankReference'] ?? "",
    paymentDetail: json['paymentDetail'] != null
        ? PaymentDetail.fromJson(Map<String, dynamic>.from(json['paymentDetail']))
        : null,
    discountType: DiscountType.tryFromApi(json['discountType'] as String?),
    discountValue: json['discountValue'] as int? ?? 0,
    itemDiscounts: json['itemDiscounts'] as int? ?? 0,
    invoiceDiscount: json['invoiceDiscount'] as int? ?? 0,
    totalCost: json['totalCost'],
    total: json['total'],
    paidAt: json['paidAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['paidAt']) : null,
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
    updatedAt: json['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt']) : null,
    createdBy: UserInfo.fromJson(json['createdBy']),
    invoicedBy: json['invoicedBy'] != null
        ? UserInfo.fromJson(json['invoicedBy'])
        : null,
    shiftId: json['shiftId'] as String?,
    cancelledAt: json['cancelledAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch((json['cancelledAt'] as num).toInt())
        : null,
    cancelledBy: json['cancelledBy'] != null
        ? UserInfo.fromJson(json['cancelledBy'] as Map<String, dynamic>)
        : null,
    cancellationReason: json['cancellationReason'] as String?,
    cancellationRequestId: json['cancellationRequestId'] as String?,
  );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'id': id,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    });
    return data;
  }
}
