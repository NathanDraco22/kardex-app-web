import 'package:kardex_app_front/src/core/app_config_manager.dart';
import 'package:kardex_app_front/src/data/servin_data_source.dart';
import 'package:kardex_app_front/src/domain/models/servin/servin.dart';
import 'package:kardex_app_front/src/domain/responses/servin_status_response.dart';

class ServinRepository {
  ServinRepository({required this.servinDataSource});

  final ServinDataSource servinDataSource;

  Future<Servin> getActiveServin(String apiKey, String nickname) async {
    final res = await servinDataSource.getActiveServin(apiKey, nickname);
    final servin = Servin.fromJson(res);
    await AppConfigManager().setConfig(servin.toJson());
    return servin;
  }

  Future<Servin?> getCurrentServinFromLocal() async {
    final config = await AppConfigManager().getConfig();
    if (config == null) return null;
    return Servin.fromJson(config);
  }

  Future<void> clearCurrentServin() async {
    await AppConfigManager().clearConfig();
  }

  Future<Servin?> refreshServinStatus() async {
    final res = await servinDataSource.getServinStatus();
    final servinResponse = ServinStatusResponse.fromJson(res);

    final localServin = await getCurrentServinFromLocal();
    if (localServin == null) return null;

    final updatedServin = localServin.copyWith(
      isActive: servinResponse.isActive,
      isMultiBranch: servinResponse.isMultiBranch,
    );

    await AppConfigManager().setConfig(updatedServin.toJson());

    return updatedServin;
  }
}
