import 'package:kardex_app_front/src/domain/models/common/transfer_item.dart';
import 'package:kardex_app_front/src/domain/models/common/user_info.dart';

enum TransferStatus {
  inTransit("Proceso"),
  received("Recibido"),
  cancelled("Cancelado")
  ;

  const TransferStatus(this.label);
  final String label;

  String toJson() => name;
  static TransferStatus fromJson(String json) => TransferStatus.values.byName(json);
}

class BaseTransfer {
  final String origin;
  final String originName;
  final String destination;
  final String destinationName;
  final String docNumber;
  final String description;
  final TransferStatus status;
  final List<TransferItem> items;
  final UserInfo createdBy;
  final UserInfo? receivedBy;
  final int? receivedAt;
  final UserInfo? cancelledBy;
  final int? cancelledAt;

  BaseTransfer({
    required this.origin,
    required this.originName,
    required this.destination,
    required this.destinationName,
    this.docNumber = "",
    this.description = "",
    required this.status,
    required this.items,
    required this.createdBy,
    this.receivedBy,
    this.receivedAt,
    this.cancelledBy,
    this.cancelledAt,
  });

  factory BaseTransfer.fromJson(Map<String, dynamic> json) => BaseTransfer(
    origin: json['origin'],
    originName: json['originName'],
    destination: json['destination'],
    destinationName: json['destinationName'],
    docNumber: json['docNumber'],
    description: json["description"] ?? "",
    status: TransferStatus.fromJson(json['status']),
    items: (json['items'] as List).map((e) => TransferItem.fromJson(e)).toList(),
    createdBy: UserInfo.fromJson(json['createdBy']),
    receivedBy: json['receivedBy'] != null ? UserInfo.fromJson(json['receivedBy']) : null,
    receivedAt: json['receivedAt'],
    cancelledBy: json['cancelledBy'] != null ? UserInfo.fromJson(json['cancelledBy']) : null,
    cancelledAt: json['cancelledAt'],
  );

  Map<String, dynamic> toJson() => {
    'origin': origin,
    'originName': originName,
    'destination': destination,
    'destinationName': destinationName,
    'docNumber': docNumber,
    'status': status.toJson(),
    'items': items.map((e) => e.toJson()).toList(),
    'createdBy': createdBy.toJson(),
    if (receivedBy != null) 'receivedBy': receivedBy!.toJson(),
    if (receivedAt != null) 'receivedAt': receivedAt,
    if (cancelledBy != null) 'cancelledBy': cancelledBy!.toJson(),
    if (cancelledAt != null) 'cancelledAt': cancelledAt,
  };
}

class CreateTransfer extends BaseTransfer {
  CreateTransfer({
    required super.origin,
    required super.originName,
    required super.destination,
    required super.destinationName,
    super.docNumber = "",
    super.description = "",
    required super.status,
    required super.items,
    required super.createdBy,
    super.receivedBy,
    super.receivedAt,
    super.cancelledBy,
    super.cancelledAt,
  });
}

class UpdateTransfer {
  UpdateTransfer();
}

class ReceiveTransferIntent {
  final int receivedAt;
  final UserInfo receivedBy;
  final TransferStatus status;

  ReceiveTransferIntent({
    required this.receivedAt,
    required this.receivedBy,
    this.status = TransferStatus.received,
  });

  Map<String, dynamic> toJson() => {
    'receivedAt': receivedAt,
    'receivedBy': receivedBy,
    'status': status.name,
  };

  factory ReceiveTransferIntent.fromJson(Map<String, dynamic> json) => ReceiveTransferIntent(
    receivedAt: json['receivedAt'] as int,
    receivedBy: UserInfo.fromJson(json['receivedBy'] as Map<String, dynamic>),
    status: TransferStatus.fromJson(json['status'] as String),
  );
}

class CancelTransferIntent {
  final int cancelledAt;
  final UserInfo cancelledBy;
  final TransferStatus status;

  CancelTransferIntent({
    required this.cancelledAt,
    required this.cancelledBy,
    this.status = TransferStatus.cancelled,
  });

  Map<String, dynamic> toJson() => {
    'cancelledAt': cancelledAt,
    'cancelledBy': cancelledBy,
    'status': status.name,
  };

  factory CancelTransferIntent.fromJson(Map<String, dynamic> json) => CancelTransferIntent(
    cancelledAt: json['cancelledAt'] as int,
    cancelledBy: UserInfo.fromJson(json['cancelledBy'] as Map<String, dynamic>),
    status: TransferStatus.fromJson(json['status'] as String),
  );
}

class TransferInDb extends BaseTransfer {
  final String id;
  final int createdAt;
  final int? updatedAt;

  int get costTotal {
    final total = items.fold(
      0,
      (previousValue, element) => previousValue + (element.cost * element.quantity),
    );
    return total;
  }

  TransferInDb({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required super.origin,
    required super.originName,
    required super.destination,
    required super.destinationName,
    super.description,
    super.docNumber = "",
    required super.status,
    required super.items,
    required super.createdBy,
    super.receivedBy,
    super.receivedAt,
    super.cancelledBy,
    super.cancelledAt,
  });

  factory TransferInDb.fromJson(Map<String, dynamic> json) => TransferInDb(
    id: json['id'],
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
    origin: json['origin'],
    originName: json['originName'],
    destination: json['destination'],
    destinationName: json['destinationName'],
    description: json["description"] ?? "",
    docNumber: json['docNumber'],
    status: TransferStatus.fromJson(json['status']),
    items: (json['items'] as List).map((e) => TransferItem.fromJson(e)).toList(),
    createdBy: UserInfo.fromJson(json['createdBy']),
    receivedBy: json['receivedBy'] != null ? UserInfo.fromJson(json['receivedBy']) : null,
    receivedAt: json['receivedAt'],
    cancelledBy: json['cancelledBy'] != null ? UserInfo.fromJson(json['cancelledBy']) : null,
    cancelledAt: json['cancelledAt'],
  );
}
