import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

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
