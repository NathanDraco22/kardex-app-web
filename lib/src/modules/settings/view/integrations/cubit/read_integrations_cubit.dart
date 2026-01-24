import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/integration/integration_model.dart';
import 'package:kardex_app_front/src/domain/repositories/integrations_repository.dart';

part 'read_integrations_state.dart';

class ReadIntegrationsCubit extends Cubit<ReadIntegrationsState> {
  final IntegrationsRepository integrationsRepository;

  ReadIntegrationsCubit(this.integrationsRepository) : super(ReadIntegrationsInitial());

  Future<void> loadAllIntegrations() async {
    emit(ReadIntegrationsLoading());
    try {
      final integrations = await integrationsRepository.getAllIntegrations();
      emit(ReadIntegrationsLoaded(integrations));
    } catch (e) {
      emit(ReadIntegrationsError(e.toString()));
    }
  }
}
