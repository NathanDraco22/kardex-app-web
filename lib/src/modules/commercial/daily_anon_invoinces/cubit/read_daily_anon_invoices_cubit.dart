import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/constants/default_values.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_totals.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/constant.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

part 'read_daily_anon_invoices_state.dart';

class ReadDailyAnonInvoicesCubit extends Cubit<ReadDailyAnonInvoicesState> {
  ReadDailyAnonInvoicesCubit({required this.invoicesRepository}) : super(ReadDailyAnonInvoicesInitial()) {
    final todayMidnight = DateTimeTool.getTodayMidnight();
    startDate = todayMidnight;
  }

  DateTime? startDate;
  int offset = 0;
  String? userCreatorId;

  bool isLastPage = false;

  final InvoicesRepository invoicesRepository;

  Future<void> loadDailyPaidAnonInvoices({DateTime? startDate, String? userCreatorId}) async {
    emit(ReadDailyAnonInvoicesLoading());
    if (startDate != null) {
      this.startDate = startDate;
    }
    if (userCreatorId != null) {
      this.userCreatorId = userCreatorId;
    }
    offset = 0;
    try {
      final topEndDate = this.startDate?.add(const Duration(days: 1));
      final result = await invoicesRepository.getPaidInvoices(
        clientId: kSaleClientId,
        startDate: this.startDate?.millisecondsSinceEpoch,
        endDate: topEndDate?.millisecondsSinceEpoch,
        offset: offset,
        userCreatorId: this.userCreatorId,
      );

      final totals = await invoicesRepository.getTotalFromPaidInvoices(
        clientId: kSaleClientId,
        startDate: this.startDate?.millisecondsSinceEpoch,
        endDate: topEndDate?.millisecondsSinceEpoch,
        userCreatorId: this.userCreatorId,
      );

      offset += result.data.length;

      isLastPage = result.data.length < paginationItems;

      emit(ReadDailyAnonInvoicesSuccess(result.data, offset, totals));
    } catch (e) {
      emit(ReadDailyAnonInvoicesError(e.toString()));
    }
  }

  Future<void> nextPage() async {
    if (isLastPage) return;
    final currentState = state;
    if (currentState is! ReadDailyAnonInvoicesSuccess) return;
    if (currentState is ReadSearchingInvoice) return;
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
        userCreatorId: userCreatorId,
      );
      offset += result.data.length;
      isLastPage = result.data.length < paginationItems;
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

  void clearFilters() {
    startDate = DateTimeTool.getTodayMidnight();
    offset = 0;
    userCreatorId = null;
    loadDailyPaidAnonInvoices(startDate: startDate);
  }
}
