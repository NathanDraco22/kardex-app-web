import 'supplier_model.dart';

class SuppliersResponseModel {
  int count;
  List<SupplierInDb> data;

  SuppliersResponseModel({
    required this.count,
    required this.data,
  });

  factory SuppliersResponseModel.fromJson(Map json) => SuppliersResponseModel(
    count: json["count"],
    data: List<SupplierInDb>.from(
      json["data"].map(
        (x) => SupplierInDb.fromJson(x),
      ),
    ),
  );

  Map<String, dynamic> toJson() => {
    "count": count,
    "data": List<dynamic>.from(
      data.map(
        (x) => x.toJson(),
      ),
    ),
  };
}
