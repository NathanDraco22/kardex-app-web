/// Decisión sobre cómo vincular una orden o cotización convertida a factura
/// con el turno de caja del usuario.
///
/// Los tres estados son excluyentes:
/// - [never]: no se interactúa con turnos.
/// - [optional]: se vincula al turno abierto si existe; si no, se factura sin
///   turno.
/// - [required]: se exige un turno abierto en la sucursal para convertir.
enum ConvertedOrderShiftPolicy {
  never(linkToShift: false, requiresOpenShift: false),
  optional(linkToShift: true, requiresOpenShift: false),
  required(linkToShift: true, requiresOpenShift: true);

  const ConvertedOrderShiftPolicy({
    required this.linkToShift,
    required this.requiresOpenShift,
  });

  /// Indica si la factura resultante debe intentar cargarse a un turno.
  final bool linkToShift;

  /// Indica si la conversión debe bloquearse cuando no hay turno abierto.
  final bool requiresOpenShift;
}
