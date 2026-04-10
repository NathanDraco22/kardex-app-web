import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_totals.dart';
import 'package:kardex_app_front/src/domain/query_params/history_params.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
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

  InvoiceQueryParams params = InvoiceQueryParams();

  final InvoicesRepository invoicesRepository;

  Future<void> loadPaidInvoices() async {
    emit(ReadDailyClientInvoicesLoading());
    offset = 0;
    try {
      final topEndDate = endDate?.add(const Duration(days: 1));

      params = InvoiceQueryParams()
        ..branchId = BranchesTool.getCurrentBranchId()
        ..clientId = null
        ..startDate = DateTime.fromMillisecondsSinceEpoch(startDate?.millisecondsSinceEpoch ?? 0)
        ..endDate = DateTime.fromMillisecondsSinceEpoch(topEndDate?.millisecondsSinceEpoch ?? 0)
        ..createdBy = userCreatorId;

      final result = await invoicesRepository.getAllInvoices(params);

      final totals = await invoicesRepository.getTotalFromInvoices(params);

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
