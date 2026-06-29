class TransferQueryParams {
  final int offset;
  final int limit;
  final String? status;
  final String? origin;
  final String? destination;

  const TransferQueryParams({
    this.offset = 0,
    this.limit = 50,
    this.status,
    this.origin,
    this.destination,
  });

  Map<String, String> toQueryMap() {
    return {
      'offset': offset.toString(),
      'limit': limit.toString(),
      'status': ?status,
      'origin': ?origin,
      'destination': ?destination,
    };
  }
}
