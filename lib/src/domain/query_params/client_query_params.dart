class ClientQueryParams {
  int offset = 0;
  int limit = 50;

  Map<String, String> toMap() {
    return {
      'offset': offset.toString(),
      'limit': limit.toString(),
    };
  }
}
