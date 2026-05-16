class ServinStatusResponse {
  final String nickname;
  final bool isActive;
  final bool isMultiBranch;

  ServinStatusResponse({
    required this.nickname,
    required this.isActive,
    required this.isMultiBranch,
  });

  factory ServinStatusResponse.fromJson(Map<String, dynamic> json) {
    return ServinStatusResponse(
      nickname: json['nickname'],
      isActive: json['isActive'],
      isMultiBranch: json['isMultiBranch'],
    );
  }
}
