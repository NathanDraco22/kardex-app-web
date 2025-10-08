import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/constants/default_values.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_totals.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

part 'read_daily_anon_invoices_state.dart';

class ReadDailyAnonInvoicesCubit extends Cubit<ReadDailyAnonInvoicesState> {
  ReadDailyAnonInvoicesCubit({required this.invoicesRepository}) : super(ReadDailyAnonInvoicesInitial()) {
    final todayMidnight = DateTimeTool.getTodayMidnight();
    startDate = todayMidnight;
  }

  DateTime? startDate;
  int offset = 0;

  final InvoicesRepository invoicesRepository;

  Future<void> loadDailyPaidAnonInvoices({DateTime? startDate}) async {
    emit(ReadDailyAnonInvoicesLoading());
    this.startDate = startDate;
    offset = 0;
    try {
      final topEndDate = startDate?.add(const Duration(days: 1));
      final result = await invoicesRepository.getPaidInvoices(
        clientId: kSaleClientId,
        startDate: startDate?.millisecondsSinceEpoch,
        endDate: topEndDate?.millisecondsSinceEpoch,
        offset: offset,
      );
      offset += result.data.length;

      final totals = await invoicesRepository.getTotalFromPaidInvoices(
        clientId: kSaleClientId,
        startDate: startDate?.millisecondsSinceEpoch,
        endDate: topEndDate?.millisecondsSinceEpoch,
        offset: offset,
      );

      emit(ReadDailyAnonInvoicesSuccess(result.data, offset, totals));
    } catch (e) {
      emit(ReadDailyAnonInvoicesError(e.toString()));
    }
  }

  Future<void> nextPage() async {
    final currentState = state;

    if (currentState is! ReadDailyAnonInvoicesSuccess) return;

    emit(
      ReadSearchingInvoice(
        currentState.invoices,
        currentState.totalCount,
        currentState.totals,
      ),
    );
    try {
      final topEndDate = startDate?.add(const Duration(days: 1));

      final result = await invoicesRepository.getPaidInvoices(
        clientId: kSaleClientId,
        startDate: startDate?.millisecondsSinceEpoch,
        endDate: topEndDate?.millisecondsSinceEpoch,
        offset: offset,
      );
      offset += result.data.length;
      emit(
        ReadDailyAnonInvoicesSuccess(
          [...currentState.invoices, ...result.data],
          offset,
          currentState.totals,
        ),
      );
    } catch (e) {
      emit(ReadDailyAnonInvoicesError(e.toString()));
    }
  }
}
