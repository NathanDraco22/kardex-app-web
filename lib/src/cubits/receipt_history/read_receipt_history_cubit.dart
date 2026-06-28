import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_receipt_history_state.dart';

class ReadReceiptHistoryCubit extends Cubit<ReadReceiptHistoryState> {
  ReadReceiptHistoryCubit(this.receiptsRepository) : super(ReadReceiptHistoryInitial());

  final ReceiptsRepository receiptsRepository;

  InvoiceQueryParams params = InvoiceQueryParams();
  bool _isLastPage = false;

  Future<void> loadReceiptsHistory(String branchId) async {
    emit(ReadReceiptHistoryLoading());
    params.offset = 0;
    params.branchId = branchId;
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

  void setDefaultParams(String branchId) {
    params = InvoiceQueryParams();
    _isLastPage = false;
    loadReceiptsHistory(branchId);
  }
}
