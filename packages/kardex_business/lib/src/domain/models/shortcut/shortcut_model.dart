class Shortcut {
  final String routeName;
  final DateTime createdAt;

  const Shortcut({
    required this.routeName,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'routeName': routeName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Shortcut.fromJson(Map<String, dynamic> json) {
    return Shortcut(
      routeName: json['routeName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
