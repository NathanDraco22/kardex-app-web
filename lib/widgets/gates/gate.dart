import 'dart:async';

import 'package:kardex_app_front/widgets/gates/gate_filter.dart';
import 'package:material_ui/material_ui.dart';

/// Modo de combinación para los filtros de [Gate].
enum GateMatchMode {
  /// Todos los filtros deben permitir el acceso (AND lógico).
  all,

  /// Basta con que al menos un filtro permita el acceso (OR lógico).
  any,
}

/// Widget único de control de acceso y visibilidad basado en una lista de
/// [GateFilter], evitando anidar múltiples widgets Gate en el árbol.
class Gate extends StatefulWidget {
  const Gate({
    super.key,
    required this.filters,
    required this.child,
    this.matchMode = GateMatchMode.all,
    this.fallback,
    this.width,
    this.height,
  });

  final List<GateFilter> filters;
  final Widget child;
  final GateMatchMode matchMode;
  final Widget? fallback;
  final double? width;
  final double? height;

  @override
  State<Gate> createState() => _GateState();
}

class _GateState extends State<Gate> {
  final List<StreamSubscription<Object?>> _subscriptions = [];
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _subscribe();
    }
  }

  @override
  void didUpdateWidget(covariant Gate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_filtersMatch(oldWidget.filters, widget.filters)) {
      _unsubscribe();
      _subscribe();
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  bool _filtersMatch(List<GateFilter> a, List<GateFilter> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _subscribe() {
    final streams = <Stream<Object?>>{};
    for (final filter in widget.filters) {
      streams.addAll(filter.watchStreams(context));
    }

    for (final stream in streams) {
      _subscriptions.add(
        stream.listen((_) {
          if (mounted) setState(() {});
        }),
      );
    }
  }

  void _unsubscribe() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  @override
  Widget build(BuildContext context) {
    final (isAllowed, blockingFilter) = _evaluate(context);

    final Widget result;
    if (isAllowed) {
      result = widget.child;
    } else {
      result =
          blockingFilter?.buildFallback(context) ??
          widget.fallback ??
          const SizedBox.shrink();
    }

    if (widget.width != null || widget.height != null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: result,
      );
    }

    return result;
  }

  (bool, GateFilter?) _evaluate(BuildContext context) {
    if (widget.filters.isEmpty) {
      return (true, null);
    }

    switch (widget.matchMode) {
      case GateMatchMode.all:
        for (final filter in widget.filters) {
          if (!filter.isAllowed(context)) {
            return (false, filter);
          }
        }
        return (true, null);

      case GateMatchMode.any:
        GateFilter? fallbackCandidate;
        for (final filter in widget.filters) {
          if (filter.isAllowed(context)) {
            return (true, null);
          }
          fallbackCandidate ??=
              filter.buildFallback(context) != null ? filter : null;
        }
        return (false, fallbackCandidate);
    }
  }
}
