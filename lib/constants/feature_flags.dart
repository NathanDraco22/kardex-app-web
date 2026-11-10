/// Banderas de compilación para habilitar u ocultar funcionalidades.
///
/// Se definen con `bool.fromEnvironment` para poder activarlas o desactivarlas
/// mediante `--dart-define`, por ejemplo:
/// `flutter run --dart-define=SHOW_UNIT_SCALES=false`.
class FeatureFlags {
  FeatureFlags._();

  /// Muestra la gestión de escalas de unidades y los presets asociados.
  ///
  /// Por defecto las escalas se muestran. Para ocultarlas:
  /// `--dart-define=SHOW_UNIT_SCALES=false`.
  static const bool showUnitScales = bool.fromEnvironment(
    'SHOW_UNIT_SCALES',
    defaultValue: true,
  );
}
