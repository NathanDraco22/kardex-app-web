import 'package:kardex_app_front/src/domain/models/integration/telegram_integration.dart';

class IntegrationModel {
  final String id;
  final TelegramIntegration telegram;
  final int createdAt;
  final int? updatedAt;

  IntegrationModel({
    required this.id,
    required this.telegram,
    required this.createdAt,
    this.updatedAt,
  });

  factory IntegrationModel.fromJson(Map<String, dynamic> json) {
    return IntegrationModel(
      id: json['id'],
      telegram: TelegramIntegration.fromJson(
        json['telegram'] ?? {},
      ),
      createdAt: json['createdAt'] ?? 0,
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'telegram': telegram.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class UpdateIntegration {
  final TelegramIntegration? telegram;

  UpdateIntegration({
    this.telegram,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (telegram != null) {
      data['telegram'] = telegram!.toJson();
    }
    return data;
  }
}
