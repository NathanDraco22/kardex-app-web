class ListResponse<T> {
  final int count;
  final List<T> data;

  ListResponse({required this.count, required this.data});

  factory ListResponse.fromJson(
    Map json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ListResponse<T>(
      count: json['count'] as int,
      data: (json['data'] as List<dynamic>)
          .map(
            (item) => fromJsonT(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
