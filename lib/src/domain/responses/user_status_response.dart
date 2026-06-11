class UserStatusResponse {
  final String userId;
  final bool isActive;

  UserStatusResponse({
    required this.userId,
    required this.isActive,
  });

  factory UserStatusResponse.fromJson(Map<String, dynamic> json) {
    return UserStatusResponse(
      userId: json['userId'],
      isActive: json['isActive'],
    );
  }
}
