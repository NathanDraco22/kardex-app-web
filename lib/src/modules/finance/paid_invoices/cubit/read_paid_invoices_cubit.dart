import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_paid_invoices_state.dart';

class ReadPaidInvoicesCubit extends Cubit<ReadPaidInvoicesState> {
  ReadPaidInvoicesCubit({required this.invoicesRepository}) : super(ReadPaidInvoicesInitial()) {
    final todayMidnight = DateTimeTool.getTodayMidnight();
    invoiceQueryParams.startDate = todayMidnight;
    invoiceQueryParams.endDate = todayMidnight;
  }

  final InvoicesRepository invoicesRepository;

  InvoicePayAtQueryParams invoiceQueryParams = InvoicePayAtQueryParams();

  set endDate(DateTime? value) {
    invoiceQueryParams.endDate = value;
  }

  set startDate(DateTime? value) {
    invoiceQueryParams.startDate = value;
  }

  DateTime? get startDate => invoiceQueryParams.startDate;

  DateTime? get endDate => invoiceQueryParams.endDate;

  set clientId(String? value) {
    invoiceQueryParams.clientId = value;
  }

  String? get clientId => invoiceQueryParams.clientId;

  bool isLastPage = false;

  Future<void> loadPaidInvoices(String branchId) async {
    emit(ReadPaidInvoicesLoading());

    isLastPage = false;

    try {
      final topEndDate = invoiceQueryParams.endDate?.add(const Duration(days: 1));
      final result = await invoicesRepository.getPaidInvoices(
        branchId: branchId,
        clientId: invoiceQueryParams.clientId,
        startDate: invoiceQueryParams.startDate!.millisecondsSinceEpoch,
        endDate: topEndDate!.millisecondsSinceEpoch,
        offset: invoiceQueryParams.offset,
      );
      invoiceQueryParams.offset += result.data.length;

      if (result.data.length < invoiceQueryParams.limit) {
        isLastPage = true;
      }

      final totals = await invoicesRepository.getTotalFromPaidInvoices(
        branchId: branchId,
        clientId: invoiceQueryParams.clientId,
        startDate: invoiceQueryParams.startDate!.millisecondsSinceEpoch,
        endDate: topEndDate.millisecondsSinceEpoch,
      );

      emit(ReadPaidInvoicesSuccess(result.data, invoiceQueryParams.offset, totals));
    } catch (e) {
      emit(ReadPaidInvoicesError(e.toString()));
    }
  }

  Future<void> nextPage(String branchId) async {
    if (isLastPage) return;
    final currentState = state;
    if (currentState is ReadSearchingInvoice) return;
    if (currentState is! ReadPaidInvoicesSuccess) return;

    emit(
      ReadSearchingInvoice(
        currentState.invoices,
        currentState.totalCount,
        currentState.totals,
      ),
    );
    try {
      final topEndDate = invoiceQueryParams.endDate?.add(const Duration(days: 1));

      final result = await invoicesRepository.getPaidInvoices(
        branchId: branchId,
        clientId: invoiceQueryParams.clientId,
        startDate: invoiceQueryParams.startDate!.millisecondsSinceEpoch,
        endDate: topEndDate!.millisecondsSinceEpoch,
        offset: invoiceQueryParams.offset,
      );
      invoiceQueryParams.offset += result.data.length;

      if (result.data.length < invoiceQueryParams.limit) {
        isLastPage = true;
      }

      emit(
        ReadPaidInvoicesSuccess(
          [...currentState.invoices, ...result.data],
          invoiceQueryParams.offset,
          currentState.totals,
        ),
      );
    } catch (e) {
      emit(ReadPaidInvoicesError(e.toString()));
    }
  }

  void clearFilters() {
    final todayMidnight = DateTimeTool.getTodayMidnight();
    invoiceQueryParams.startDate = todayMidnight;
    invoiceQueryParams.endDate = todayMidnight;
    invoiceQueryParams.clientId = null;
    invoiceQueryParams.offset = 0;
  }
}
