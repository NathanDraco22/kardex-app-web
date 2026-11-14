/// Presets de etiquetas para el identificador tributario de la sucursal por país.
enum AppTaxIdLabel {
  ruc(label: 'RUC', countries: 'Nicaragua, Perú, Ecuador, Paraguay'),
  rtn(label: 'RTN', countries: 'Honduras'),
  nit(label: 'NIT', countries: 'Guatemala, Colombia, El Salvador, Bolivia'),
  rfc(label: 'RFC', countries: 'México'),
  rnc(label: 'RNC', countries: 'República Dominicana'),
  cedulaJuridica(label: 'Cédula Jurídica', countries: 'Costa Rica'),
  rut(label: 'RUT', countries: 'Chile, Uruguay'),
  cuit(label: 'CUIT', countries: 'Argentina'),
  rif(label: 'RIF', countries: 'Venezuela'),
  nif(label: 'NIF', countries: 'España');

  const AppTaxIdLabel({
    required this.label,
    required this.countries,
  });

  final String label;
  final String countries;

  /// Busca un preset que coincida (insensible a mayúsculas) o retorna `null` si es personalizado.
  static AppTaxIdLabel? tryFromLabel(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final preset in AppTaxIdLabel.values) {
      if (preset.label.toLowerCase() == normalized) {
        return preset;
      }
    }
    return null;
  }

  /// Normaliza una etiqueta tributaria aplicando `'RUC'` como fallback si viene vacía.
  static String normalize(String? value, {String fallback = 'RUC'}) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return fallback;
    return trimmed;
  }
}
