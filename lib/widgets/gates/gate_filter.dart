import 'package:material_ui/material_ui.dart';

/// Contrato base para cualquier regla de acceso o visibilidad usada en [Gate].
///
/// Funciona de manera análoga a `TextInputFormatter` en `TextField`: permite
/// encapsular condiciones independientes y componerlas en una lista plana sin
/// anidar múltiples widgets en el árbol.
abstract class GateFilter {
  const GateFilter();

  /// Evalúa de forma síncrona si este filtro permite mostrar el contenido.
  bool isAllowed(BuildContext context);

  /// Streams opcionales a los que [Gate] se suscribe para re-evaluar el filtro
  /// reactivamente cuando cambie el estado subyacente.
  Iterable<Stream<Object?>> watchStreams(BuildContext context) => const [];

  /// Fallback opcional a renderizar cuando este filtro bloquea el acceso.
  Widget? buildFallback(BuildContext context) => null;
}

/// Combinador lógico OR: permite el acceso si al menos uno de [filters] pasa.
class AnyGateFilter extends GateFilter {
  const AnyGateFilter(this.filters, {this.fallback});

  final List<GateFilter> filters;
  final Widget? fallback;

  @override
  bool isAllowed(BuildContext context) {
    return filters.any((filter) => filter.isAllowed(context));
  }

  @override
  Iterable<Stream<Object?>> watchStreams(BuildContext context) {
    return filters.expand((filter) => filter.watchStreams(context));
  }

  @override
  Widget? buildFallback(BuildContext context) => fallback;
}

/// Combinador lógico NOT: invierte el resultado de [filter].
class NotGateFilter extends GateFilter {
  const NotGateFilter(this.filter, {this.fallback});

  final GateFilter filter;
  final Widget? fallback;

  @override
  bool isAllowed(BuildContext context) => !filter.isAllowed(context);

  @override
  Iterable<Stream<Object?>> watchStreams(BuildContext context) {
    return filter.watchStreams(context);
  }

  @override
  Widget? buildFallback(BuildContext context) => fallback;
}

/// Filtro ad-hoc basado en un predicado booleano y streams opcionales.
class PredicateGateFilter extends GateFilter {
  const PredicateGateFilter(
    this.predicate, {
    this.watch,
    this.fallback,
  });

  final bool Function(BuildContext context) predicate;
  final Iterable<Stream<Object?>> Function(BuildContext context)? watch;
  final Widget? fallback;

  @override
  bool isAllowed(BuildContext context) => predicate(context);

  @override
  Iterable<Stream<Object?>> watchStreams(BuildContext context) {
    return watch?.call(context) ?? const [];
  }

  @override
  Widget? buildFallback(BuildContext context) => fallback;
}
