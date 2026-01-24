part of 'write_integration_cubit.dart';

sealed class WriteIntegrationState {}

final class WriteIntegrationInitial extends WriteIntegrationState {}

final class WriteIntegrationLoading extends WriteIntegrationState {}

final class WriteIntegrationSuccess extends WriteIntegrationState {
  final String message;

  WriteIntegrationSuccess(this.message);
}

final class WriteIntegrationError extends WriteIntegrationState {
  final String message;

  WriteIntegrationError(this.message);
}
