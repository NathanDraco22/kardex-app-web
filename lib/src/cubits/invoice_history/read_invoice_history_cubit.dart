import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_totals.dart';
import 'package:kardex_app_front/src/domain/query_params/history_params.dart';
import 'package:kardex_app_front/src/domain/repositories/invoice_repository.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';

part 'read_invoice_history_state.dart';

class ReadInvoiceHistoryCubit extends Cubit<ReadInvoiceHistoryState> {
  ReadInvoiceHistoryCubit(this.invoicesRepository) : super(ReadInvoiceHistoryInitial());

  final InvoicesRepository invoicesRepository;

  InvoiceQueryParams params = InvoiceQueryParams();
  bool _isLastPage = false;

  Future<void> loadInvoicesHistory() async {
    emit(ReadInvoiceHistoryLoading());
    params.offset = 0;
    params.branchId = BranchesTool.getCurrentBranchId();

    try {
      final invoices = await invoicesRepository.getInvoicesHistory(params);
      final totals = await invoicesRepository.getTotalFromInvoices(params);

      _isLastPage = invoices.length < params.limit;

      params.offset += invoices.length;

      emit(ReadInvoiceHistorySuccess(invoices, totals));
    } catch (error) {
      emit(ReadInvoiceHistoryError(error.toString()));
    }
  }

  Future<void> nextPage() async {
    if (_isLastPage) return;
    final currentState = state;
    if (currentState is! ReadInvoiceHistorySuccess) return;
    if (currentState is FetchingNextPage) return;

    try {
      emit(FetchingNextPage(currentState.invoices, currentState.totals));
      final invoices = await invoicesRepository.getInvoicesHistory(params);

      _isLastPage = invoices.length < params.limit;

      params.offset += invoices.length;

      emit(
        ReadInvoiceHistorySuccess(
          [...currentState.invoices, ...invoices],
          currentState.totals,
        ),
      );
    } catch (e) {
      emit(ReadInvoiceHistoryError(e.toString()));
    }
  }

  void setDefaultParams() {
    params = InvoiceQueryParams();
    _isLastPage = false;
    loadInvoicesHistory();
  }
}
