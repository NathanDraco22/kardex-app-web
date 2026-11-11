import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'near_expiration_state.dart';

class NearExpirationCubit extends Cubit<NearExpirationState> {
  final ExpirationLogsRepository expirationLogsRepository;

  NearExpirationCubit({
    required this.expirationLogsRepository,
  }) : super(const NearExpirationInitial());

  Future<void> checkNearExpirations(String branchId, {int limit = 10}) async {
    if (branchId.isEmpty) {
      emit(const NearExpirationInitial());
      return;
    }

    try {
      emit(const NearExpirationLoading());
      final logs = await expirationLogsRepository.getNearExpirationLogs(
        branchId,
        limit: limit,
      );
      if (isClosed) return;
      emit(NearExpirationLoaded(logs));
    } catch (e) {
      if (isClosed) return;
      emit(NearExpirationError(e.toString()));
    }
  }

  void clear() {
    emit(const NearExpirationInitial());
  }
}
