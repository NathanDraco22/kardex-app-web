class ServinStatusResponse {
  final bool isActive;
  final bool isMultiBranch;

  ServinStatusResponse({
    required this.isActive,
    required this.isMultiBranch,
  });

  factory ServinStatusResponse.fromJson(Map<String, dynamic> json) {
    return ServinStatusResponse(
      isActive: json['isActive'],
      isMultiBranch: json['isMultiBranch'],
    );
  }
}
