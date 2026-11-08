import 'package:get_it/get_it.dart';
import 'package:kardex_app_front/src/services/thermal_printer_service.dart';

final getIt = GetIt.instance;

void initServices() {
  if (!getIt.isRegistered<ThermalPrinterService>()) {
    getIt.registerLazySingleton<ThermalPrinterService>(() => ThermalPrinterService());
  }
}
