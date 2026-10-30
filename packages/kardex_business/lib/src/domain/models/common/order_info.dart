import 'package:kardex_business/src/domain/models/common/user_info.dart';

class OrderInfo {
  final String id;
  final String docNumber;
  final DateTime createdAt;
  final UserInfo createdBy;

  OrderInfo({
    this.id = "",
    this.docNumber = "",
    required this.createdAt,
    required this.createdBy,
  });

  factory OrderInfo.fromJson(Map<String, dynamic> json) => OrderInfo(
    id: json['id'] ?? "",
    docNumber: json['docNumber'] ?? "",
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
    createdBy: UserInfo.fromJson(json['createdBy']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'docNumber': docNumber,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'createdBy': createdBy.toJson(),
  };
}
