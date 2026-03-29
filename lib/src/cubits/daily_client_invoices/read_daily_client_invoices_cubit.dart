import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_totals.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/constant.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

part 'read_daily_client_invoices_state.dart';

class ReadDailyClientInvoicesCubit extends Cubit<ReadDailyClientInvoicesState> {
  ReadDailyClientInvoicesCubit({required this.invoicesRepository}) : super(ReadDailyClientInvoicesInitial()) {
    startDate = DateTimeTool.getTodayMidnight();
    endDate = startDate; // Same day default
  }

  DateTime? startDate;
  DateTime? endDate;
  int offset = 0;
  String? userCreatorId;

  bool isLastPage = false;

  final InvoicesRepository invoicesRepository;

  Future<void> loadPaidInvoices() async {
    emit(ReadDailyClientInvoicesLoading());
    offset = 0;
    try {
      final topEndDate = endDate?.add(const Duration(days: 1));

      final result = await invoicesRepository.getPaidInvoices(
        clientId: null, // null fetches all clients
        startDate: startDate?.millisecondsSinceEpoch,
        endDate: topEndDate?.millisecondsSinceEpoch,
        offset: offset,
        userCreatorId: userCreatorId,
      );

      final totals = await invoicesRepository.getTotalFromPaidInvoices(
        clientId: null, // null fetches all clients
        startDate: startDate?.millisecondsSinceEpoch,
        endDate: topEndDate?.millisecondsSinceEpoch,
        userCreatorId: userCreatorId,
      );

      offset += result.data.length;
      isLastPage = result.data.length < paginationItems;

      emit(ReadDailyClientInvoicesSuccess(result.data, offset, totals));
    } catch (e) {
      emit(ReadDailyClientInvoicesError(e.toString()));
    }
  }

  Future<void> nextPage() async {
    if (isLastPage) return;
    final currentState = state;
    if (currentState is! ReadDailyClientInvoicesSuccess) return;
    if (currentState is ReadDailyClientInvoicesLoadingMore) return;

    emit(
      ReadDailyClientInvoicesLoadingMore(
        currentState.invoices,
        currentState.totalCount,
        currentState.totals,
      ),
    );
    try {
      final topEndDate = endDate?.add(const Duration(days: 1));

      final result = await invoicesRepository.getPaidInvoices(
        clientId: null, // null fetches all clients
        startDate: startDate?.millisecondsSinceEpoch,
        endDate: topEndDate?.millisecondsSinceEpoch,
        offset: offset,
        userCreatorId: userCreatorId,
      );

      offset += result.data.length;
      isLastPage = result.data.length < paginationItems;

      emit(
        ReadDailyClientInvoicesSuccess(
          [...currentState.invoices, ...result.data],
          offset,
          currentState.totals,
        ),
      );
    } catch (e) {
      emit(ReadDailyClientInvoicesError(e.toString()));
    }
  }

  void clearFilters() {
    startDate = DateTimeTool.getTodayMidnight();
    endDate = startDate;
    offset = 0;
    userCreatorId = null;
    loadPaidInvoices();
  }
}
