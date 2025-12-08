class Servin {
  Servin({
    required this.name,
    required this.url,
    required this.isActive,
    this.isMultiBranch = false,
  });

  final String name;
  final String url;
  final bool isActive;
  final bool isMultiBranch;

  factory Servin.fromJson(Map<String, dynamic> json) {
    return Servin(
      name: json['name'],
      url: json['url'],
      isActive: json['isActive'],
      isMultiBranch: json['isMultiBranch'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'url': url,
      'isActive': isActive,
      'isMultiBranch': isMultiBranch,
    };
    return map;
  }

  Servin copyWith({
    String? name,
    String? url,
    bool? isActive,
    bool? isMultiBranch,
  }) {
    return Servin(
      name: name ?? this.name,
      url: url ?? this.url,
      isActive: isActive ?? this.isActive,
      isMultiBranch: isMultiBranch ?? this.isMultiBranch,
    );
  }
}
