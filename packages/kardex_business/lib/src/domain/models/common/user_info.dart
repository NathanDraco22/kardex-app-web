class UserInfo {
  const UserInfo({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory UserInfo.fromJson(Map json) {
    return UserInfo(
      id: json['id'],
      name: json['name'],
    );
  }
}
