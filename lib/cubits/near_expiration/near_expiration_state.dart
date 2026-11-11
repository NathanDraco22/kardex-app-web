part of 'near_expiration_cubit.dart';

sealed class NearExpirationState {
  const NearExpirationState();
}

final class NearExpirationInitial extends NearExpirationState {
  const NearExpirationInitial();
}

final class NearExpirationLoading extends NearExpirationState {
  const NearExpirationLoading();
}

final class NearExpirationLoaded extends NearExpirationState {
  final List<ExpirationLogInDb> logs;

  const NearExpirationLoaded(this.logs);

  bool get hasLogs => logs.isNotEmpty;
  int get count => logs.length;
  ExpirationLogInDb? get nearestLog => logs.isNotEmpty ? logs.first : null;
}

final class NearExpirationError extends NearExpirationState {
  final String message;

  const NearExpirationError(this.message);
}
