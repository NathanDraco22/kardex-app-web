class UserStatusResponse {
  final bool isActive;

  UserStatusResponse({
    required this.isActive,
  });

  factory UserStatusResponse.fromJson(Map<String, dynamic> json) {
    return UserStatusResponse(
      isActive: json['isActive'],
    );
  }
}
