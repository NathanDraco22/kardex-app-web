import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_totals.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

part 'read_daily_invoices_state.dart';

class ReadDailyInvoicesCubit extends Cubit<ReadDailyInvoicesState> {
  ReadDailyInvoicesCubit({required this.invoicesRepository}) : super(ReadDailyInvoicesInitial()) {
    final todayMidnight = DateTimeTool.getTodayMidnight();
    currentStartDate = todayMidnight;
  }

  DateTime? currentStartDate;
  int currentOffset = 0;
  String? currentClientId;

  final InvoicesRepository invoicesRepository;

  Future<void> loadDailyPaidInvoices({int? offset}) async {
    emit(ReadDailyInvoicesLoading());
    if (offset != null) currentOffset = offset;
    try {
      final topEndDate = currentStartDate?.add(const Duration(days: 1));
      final result = await invoicesRepository.getClientInvoices(
        clientId: currentClientId,
        startDate: currentStartDate?.millisecondsSinceEpoch,
        endDate: topEndDate?.millisecondsSinceEpoch,
        offset: currentOffset,
      );

      final totals = await invoicesRepository.getTotalFromClientInvoices(
        clientId: currentClientId,
        startDate: currentStartDate?.millisecondsSinceEpoch,
        endDate: topEndDate?.millisecondsSinceEpoch,
        offset: currentOffset,
      );

      currentOffset += result.data.length;

      emit(ReadDailyInvoicesSuccess(result.data, currentOffset, totals));
    } catch (e) {
      emit(ReadDailyInvoicesError(e.toString()));
    }
  }

  Future<void> nextPage() async {
    final currentState = state;

    if (currentState is! ReadDailyInvoicesSuccess) return;

    emit(
      ReadSearchingInvoice(
        currentState.invoices,
        currentState.totalCount,
        currentState.totals,
      ),
    );
    try {
      final topEndDate = currentStartDate?.add(const Duration(days: 1));

      final result = await invoicesRepository.getPaidInvoices(
        clientId: currentClientId,
        startDate: currentStartDate?.millisecondsSinceEpoch,
        endDate: topEndDate?.millisecondsSinceEpoch,
        offset: currentOffset,
      );
      currentOffset += result.data.length;
      emit(
        ReadDailyInvoicesSuccess(
          [...currentState.invoices, ...result.data],
          currentOffset,
          currentState.totals,
        ),
      );
    } catch (e) {
      emit(ReadDailyInvoicesError(e.toString()));
    }
  }

  Future<void> reset() async {
    currentStartDate = DateTimeTool.getTodayMidnight();
    currentClientId = null;
    currentOffset = 0;
    loadDailyPaidInvoices();
  }
}
