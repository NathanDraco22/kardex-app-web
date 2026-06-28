import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/core/app_kardex_config.dart';
import 'package:kardex_business/kardex_business.dart';

part 'activation_state.dart';

class ActivationCubit extends Cubit<ActivationState> {
  ActivationCubit(this.servinRepository) : super(ActivationInitial());

  final ServinRepository servinRepository;

  Future<void> activate(String apiKey, String nickname) async {
    emit(ActivationLoading());
    try {
      final servin = await servinRepository.getActiveServin(apiKey, nickname);

      AppKardexConfig().setBaseUrl(servin.url);
      emit(ActivationSuccess(servin));
    } catch (error) {
      emit(ActivationError(error.toString()));
    }
  }
}
