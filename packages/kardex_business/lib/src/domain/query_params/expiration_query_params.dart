class ExpirationQueryParams {
  String? branchId;

  ExpirationQueryParams({this.branchId});

  Map<String, String> toMap() {
    return {
      'branchId': ?branchId,
    };
  }
}
