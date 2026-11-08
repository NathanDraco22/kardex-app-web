import 'package:kardex_business/kardex_business.dart';

sealed class ImportsState {
  const ImportsState();
}

class ImportsInitial extends ImportsState {
  const ImportsInitial();
}

class ImportsLoading extends ImportsState {
  const ImportsLoading(this.type);

  final ImportType type;
}

class ImportsSuccess extends ImportsState {
  const ImportsSuccess({
    required this.type,
    required this.result,
  });

  final ImportType type;
  final ImportResult result;
}

class ImportsError extends ImportsState {
  const ImportsError({
    required this.type,
    required this.message,
  });

  final ImportType type;
  final String message;
}
