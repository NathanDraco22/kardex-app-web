import 'package:kardex_business/src/domain/models/credit_note/credit_note.dart';

class CreditNoteQueryParams {
  String? branchId;
  String? clientId;
  CreditNoteType? type;
  CreditNoteStatus? status;

  Map<String, String> toMap() {
    return {
      if (branchId != null) 'branchId': branchId.toString(),
      if (clientId != null) 'clientId': clientId.toString(),
      if (type != null) 'type': type!.name,
      if (status != null) 'status': status!.name,
    };
  }
}
