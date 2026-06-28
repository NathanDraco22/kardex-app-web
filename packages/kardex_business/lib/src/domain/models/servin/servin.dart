class Servin {
  Servin({
    required this.name,
    required this.nickname,
    required this.url,
    required this.isActive,
    this.isMultiBranch = false,
    this.isUsingExpirationDate = true,
  });

  final String name;
  // TODO: makes required for the next version
  final String? nickname;
  final String url;
  final bool isActive;
  final bool isMultiBranch;
  final bool isUsingExpirationDate;

  factory Servin.fromJson(Map<String, dynamic> json) {
    return Servin(
      name: json['name'],
      nickname: json['nickname'],
      url: json['url'],
      isActive: json['isActive'],
      isMultiBranch: json['isMultiBranch'] ?? false,
      isUsingExpirationDate: json['isUsingExpirationDate'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'nickname': nickname,
      'url': url,
      'isActive': isActive,
      'isMultiBranch': isMultiBranch,
      'isUsingExpirationDate': isUsingExpirationDate,
    };
    return map;
  }

  Servin copyWith({
    String? name,
    String? nickname,
    String? url,
    bool? isActive,
    bool? isMultiBranch,
    bool? isUsingExpirationDate,
  }) {
    return Servin(
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      url: url ?? this.url,
      isActive: isActive ?? this.isActive,
      isMultiBranch: isMultiBranch ?? this.isMultiBranch,
      isUsingExpirationDate: isUsingExpirationDate ?? this.isUsingExpirationDate,
    );
  }
}
