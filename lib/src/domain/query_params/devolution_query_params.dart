import 'package:kardex_app_front/src/domain/models/devolution/devolution.dart';

class DevolutionQueryParams {
  String? branchId;
  String? clientId;
  DevolutionStatus? status;

  Map<String, String> toMap() {
    return {
      if (branchId != null) 'branchId': branchId.toString(),
      if (clientId != null) 'clientId': clientId.toString(),
      if (status != null) 'status': status!.name,
    };
  }
}
