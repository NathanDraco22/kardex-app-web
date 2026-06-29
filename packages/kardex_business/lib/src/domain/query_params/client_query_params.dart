class ClientQueryParams {
  int offset = 0;
  int limit = 50;
  String? group;
  bool? hasMovements;

  Map<String, String> toMap() {
    return {
      'offset': offset.toString(),
      'limit': limit.toString(),
      'group': ?group,
      'hasMovements': ?hasMovements?.toString(),
    };
  }
}
