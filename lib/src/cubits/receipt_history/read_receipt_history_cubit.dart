import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/receipt/receipt_model.dart';
import 'package:kardex_app_front/src/domain/query_params/history_params.dart';
import 'package:kardex_app_front/src/domain/repositories/receipt_repository.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';

part 'read_receipt_history_state.dart';

class ReadReceiptHistoryCubit extends Cubit<ReadReceiptHistoryState> {
  ReadReceiptHistoryCubit(this.receiptsRepository) : super(ReadReceiptHistoryInitial());

  final ReceiptsRepository receiptsRepository;

  InvoiceQueryParams params = InvoiceQueryParams();
  bool _isLastPage = false;

  Future<void> loadReceiptsHistory() async {
    emit(ReadReceiptHistoryLoading());
    params.offset = 0;
    params.branchId = BranchesTool.getCurrentBranchId();
    try {
      final receipts = await receiptsRepository.getReceiptHistory(params);
      _isLastPage = receipts.length < params.limit;

      params.offset += receipts.length;

      emit(ReadReceiptHistorySuccess(receipts));
    } catch (error) {
      emit(ReadReceiptHistoryError(error.toString()));
    }
  }

  Future<void> nextPage() async {
    if (_isLastPage) return;
    final currentState = state;
    if (currentState is! ReadReceiptHistorySuccess) return;
    if (currentState is FetchingNextPage) return;

    try {
      emit(FetchingNextPage(currentState.receipts));
      final receipts = await receiptsRepository.getReceiptHistory(params);
      _isLastPage = receipts.length < params.limit;

      params.offset += receipts.length;

      emit(
        ReadReceiptHistorySuccess(
          [...currentState.receipts, ...receipts],
        ),
      );
    } catch (e) {
      emit(ReadReceiptHistoryError(e.toString()));
    }
  }

  void setDefaultParams() {
    params = InvoiceQueryParams();
    _isLastPage = false;
    loadReceiptsHistory();
  }
}
