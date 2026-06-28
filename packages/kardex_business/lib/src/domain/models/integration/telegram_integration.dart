class TelegramIntegration {
  final bool isActive;
  final String reportId;
  final String adjustmentId;

  TelegramIntegration({
    this.isActive = false,
    this.reportId = "",
    this.adjustmentId = "",
  });

  factory TelegramIntegration.fromJson(Map<String, dynamic> json) {
    return TelegramIntegration(
      isActive: json['isActive'] ?? false,
      reportId: json['reportId'] ?? "",
      adjustmentId: json['adjustmentId'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isActive': isActive,
      'reportId': reportId,
      'adjustmentId': adjustmentId,
    };
  }

  TelegramIntegration copyWith({
    bool? isActive,
    String? reportId,
    String? adjustmentId,
  }) {
    return TelegramIntegration(
      isActive: isActive ?? this.isActive,
      reportId: reportId ?? this.reportId,
      adjustmentId: adjustmentId ?? this.adjustmentId,
    );
  }
}
