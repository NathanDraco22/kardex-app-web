import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'write_integration_state.dart';

class WriteIntegrationCubit extends Cubit<WriteIntegrationState> {
  final IntegrationsRepository integrationsRepository;

  WriteIntegrationCubit(this.integrationsRepository) : super(WriteIntegrationInitial());

  Future<void> updateIntegration(
    String integrationId,
    UpdateIntegration body,
  ) async {
    emit(WriteIntegrationLoading());
    try {
      final result = await integrationsRepository.updateIntegrationById(
        integrationId,
        body,
      );
      if (result != null) {
        emit(WriteIntegrationSuccess("Integración actualizada correctamente"));
      } else {
        emit(WriteIntegrationError("Error al actualizar la integración"));
      }
    } catch (e) {
      emit(WriteIntegrationError(e.toString()));
    }
  }
}
