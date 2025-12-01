import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/devolution/devolution.dart';

import 'package:kardex_app_front/src/domain/query_params/history_params.dart';
import 'package:kardex_app_front/src/domain/repositories/devolution_repository.dart';

part 'read_devolution_history_state.dart';

class ReadDevolutionHistoryCubit extends Cubit<ReadDevolutionHistoryState> {
  ReadDevolutionHistoryCubit(this.devolutionsRepository) : super(ReadDevolutionHistoryInitial());

  final DevolutionsRepository devolutionsRepository;

  InvoiceQueryParams params = InvoiceQueryParams();
  bool _isLastPage = false;

  Future<void> loadDevolutionsHistory() async {
    emit(ReadDevolutionHistoryLoading());
    params.offset = 0;
    try {
      final devolutions = await devolutionsRepository.getDevolutionHistory(params);
      _isLastPage = devolutions.length < params.limit;

      params.offset += devolutions.length;

      emit(ReadDevolutionHistorySuccess(devolutions));
    } catch (error) {
      emit(ReadDevolutionHistoryError(error.toString()));
    }
  }

  Future<void> nextPage() async {
    if (_isLastPage) return;
    final currentState = state;
    if (currentState is! ReadDevolutionHistorySuccess) return;
    if (currentState is FetchingNextPage) return;

    try {
      emit(FetchingNextPage(currentState.devolutions));
      final devolutions = await devolutionsRepository.getDevolutionHistory(params);
      _isLastPage = devolutions.length < params.limit;

      params.offset += devolutions.length;

      emit(
        ReadDevolutionHistorySuccess(
          [...currentState.devolutions, ...devolutions],
        ),
      );
    } catch (e) {
      emit(ReadDevolutionHistoryError(e.toString()));
    }
  }

  void setDefaultParams() {
    params = InvoiceQueryParams();
    _isLastPage = false;
    loadDevolutionsHistory();
  }
}
