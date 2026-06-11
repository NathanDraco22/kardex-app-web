class ServinStatusResponse {
  final String nickname;
  final bool isActive;
  final bool isMultiBranch;
  final bool isUsingExpirationDate;

  ServinStatusResponse({
    required this.nickname,
    required this.isActive,
    required this.isMultiBranch,
    required this.isUsingExpirationDate,
  });

  factory ServinStatusResponse.fromJson(Map<String, dynamic> json) {
    return ServinStatusResponse(
      nickname: json['nickname'],
      isActive: json['isActive'],
      isMultiBranch: json['isMultiBranch'],
      isUsingExpirationDate: json['isUsingExpirationDate'],
    );
  }
}
