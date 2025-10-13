class Servin {
  Servin({
    required this.name,
    required this.url,
    required this.isActive,
  });

  final String name;
  final String url;
  final bool isActive;

  factory Servin.fromJson(Map<String, dynamic> json) {
    return Servin(
      name: json['name'],
      url: json['url'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'url': url,
      'isActive': isActive,
    };
    return map;
  }
}
