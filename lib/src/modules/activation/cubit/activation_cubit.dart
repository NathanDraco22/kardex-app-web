import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/servin/servin.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

part 'activation_state.dart';

class ActivationCubit extends Cubit<ActivationState> {
  ActivationCubit(this.servinRepository) : super(ActivationInitial());

  final ServinRepository servinRepository;

  Future<void> activate(String apiKey, String nickname) async {
    emit(ActivationLoading());
    try {
      final servin = await servinRepository.getActiveServin(apiKey, nickname);

      HttpTools.baseUrl = servin.url;
      emit(ActivationSuccess(servin));
    } catch (error) {
      emit(ActivationError(error.toString()));
    }
  }
}
