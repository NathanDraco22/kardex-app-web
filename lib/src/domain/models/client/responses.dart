import 'package:kardex_app_front/src/domain/models/client/client_model.dart';

class ClientsResponseModel {
  final int count;
  final List<ClientInDb> data;

  ClientsResponseModel({
    required this.count,
    required this.data,
  });

  factory ClientsResponseModel.fromJson(Map json) {
    return ClientsResponseModel(
      count: json['count'],
      data: List<ClientInDb>.from(
        json['data'].map(
          (item) => ClientInDb.fromJson(item),
        ),
      ),
    );
  }
}
