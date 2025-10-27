import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'toast_state.dart';

class ToastCubit extends Cubit<ToastState> {
  ToastCubit({
    required this.expirationLogsRepository,
  }) : super(ToastInitial());

  final ExpirationLogsRepository expirationLogsRepository;

  Future<void> hasNearExpiration(String branchId) async {
    try {
      final hasExpiration = await expirationLogsRepository.hasExpiration(branchId);
      if (isClosed) return;
      if (!hasExpiration) return;
      emit(ToastMessage("Revisa la Bitácora de Vencimientos"));
    } catch (error) {
      // ignore: avoid_catches_without_on_clauses
    }
  }
}
