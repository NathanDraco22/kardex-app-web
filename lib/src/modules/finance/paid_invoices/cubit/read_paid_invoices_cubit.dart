import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_totals.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

part 'read_paid_invoices_state.dart';

class ReadPaidInvoicesCubit extends Cubit<ReadPaidInvoicesState> {
  ReadPaidInvoicesCubit({required this.invoicesRepository}) : super(ReadPaidInvoicesInitial()) {
    final todayMidnight = DateTimeTool.getTodayMidnight();
    startDate = todayMidnight;
    endDate = todayMidnight;
  }

  DateTime? startDate;
  DateTime? endDate;
  String? clientId;
  int offset = 0;

  final InvoicesRepository invoicesRepository;

  Future<void> loadPaidInvoices() async {
    emit(ReadPaidInvoicesLoading());
    offset = 0;
    try {
      final topEndDate = endDate?.add(const Duration(days: 1));
      final result = await invoicesRepository.getPaidInvoices(
        clientId: clientId,
        startDate: startDate?.millisecondsSinceEpoch,
        endDate: topEndDate?.millisecondsSinceEpoch,
        offset: offset,
      );
      offset += result.data.length;

      final totals = await invoicesRepository.getTotalFromPaidInvoices(
        clientId: clientId,
        startDate: startDate?.millisecondsSinceEpoch,
        endDate: topEndDate?.millisecondsSinceEpoch,
        offset: offset,
      );

      emit(ReadPaidInvoicesSuccess(result.data, offset, totals));
    } catch (e) {
      emit(ReadPaidInvoicesError(e.toString()));
    }
  }

  Future<void> nextPage() async {
    final currentState = state;

    if (currentState is! ReadPaidInvoicesSuccess) return;

    emit(
      ReadSearchingInvoice(
        currentState.invoices,
        currentState.totalCount,
        currentState.totals,
      ),
    );
    try {
      final topEndDate = endDate?.add(const Duration(days: 1));

      final result = await invoicesRepository.getPaidInvoices(
        clientId: clientId,
        startDate: startDate?.millisecondsSinceEpoch,
        endDate: topEndDate?.millisecondsSinceEpoch,
        offset: offset,
      );
      offset += result.data.length;
      emit(
        ReadPaidInvoicesSuccess(
          [...currentState.invoices, ...result.data],
          offset,
          currentState.totals,
        ),
      );
    } catch (e) {
      emit(ReadPaidInvoicesError(e.toString()));
    }
  }

  void clearFilters() {
    final todayMidnight = DateTimeTool.getTodayMidnight();
    startDate = todayMidnight;
    endDate = todayMidnight;
    clientId = null;
  }
}
