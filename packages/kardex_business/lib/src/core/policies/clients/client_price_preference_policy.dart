import 'package:kardex_business/src/domain/models/client/client_model.dart';

/// Decide si un cliente impone un nivel de precio preferencial.
///
/// La preferencia solo existe cuando la función global está activa, hay un
/// cliente seleccionado, el cliente tiene [ClientInDb.usePreferredPrice]
/// activo y su `defaultPriceLevel` está entre 1 y 4. Si cualquiera de esas
/// condiciones falla, el cliente significa "Sin Preferencia" y el carrito
/// conserva sus precios actuales.
///
/// La policy es pura: no hace I/O, no conoce Flutter y no consulta `getIt`.
final class ClientPricePreferencePolicy {
  const ClientPricePreferencePolicy({
    required this.client,
    required this.enabled,
  });

  final ClientInDb? client;
  final bool enabled;

  /// Normaliza la selección de precio de un cliente para el formulario.
  ///
  /// Si no hay preferencia o el nivel no está en `1..4`, devuelve "Sin
  /// Preferencia" (`false` + nivel `1`). Así un dato inválido persistido no se
  /// vuelve a enviar como una preferencia activa.
  static ({bool usePreferredPrice, int defaultPriceLevel}) normalize({
    required bool usePreferredPrice,
    required int defaultPriceLevel,
  }) {
    final validLevel = defaultPriceLevel >= 1 && defaultPriceLevel <= 4;
    final effectiveUsePreferredPrice = usePreferredPrice && validLevel;
    return (
      usePreferredPrice: effectiveUsePreferredPrice,
      defaultPriceLevel: effectiveUsePreferredPrice ? defaultPriceLevel : 1,
    );
  }

  bool get hasPreference => preferredPriceLevel != null;

  int? get preferredPriceLevel {
    if (!enabled || client == null) return null;
    if (!client!.usePreferredPrice) return null;
    final level = client!.defaultPriceLevel;
    if (level < 1 || level > 4) return null;
    return level;
  }
}
