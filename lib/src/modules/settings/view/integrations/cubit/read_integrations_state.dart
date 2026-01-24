part of 'read_integrations_cubit.dart';

sealed class ReadIntegrationsState {}

final class ReadIntegrationsInitial extends ReadIntegrationsState {}

final class ReadIntegrationsLoading extends ReadIntegrationsState {}

final class ReadIntegrationsLoaded extends ReadIntegrationsState {
  final List<IntegrationModel> integrations;

  ReadIntegrationsLoaded(this.integrations);
}

final class ReadIntegrationsError extends ReadIntegrationsState {
  final String message;

  ReadIntegrationsError(this.message);
}
