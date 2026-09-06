class TotalsQueryParams {
  String? branchId;
  DateTime? startDate;
  DateTime? endDate;
  String? userId;

  Map<String, String> toMap() {
    final Map<String, String> map = {};
    if (branchId != null) {
      map['branchId'] = branchId!;
    }
    if (startDate != null) {
      map['startDate'] = startDate!.millisecondsSinceEpoch.toString();
    }
    if (endDate != null) {
      map['endDate'] = endDate!.millisecondsSinceEpoch.toString();
    }
    if (userId != null) {
      map['userId'] = userId!;
    }
    return map;
  }
}
