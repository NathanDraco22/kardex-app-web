import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';


part 'read_daily_anon_invoices_state.dart';

class ReadDailyAnonInvoicesCubit extends Cubit<ReadDailyAnonInvoicesState> {
  ReadDailyAnonInvoicesCubit({
    required this.invoicesRepository,
    this.defaultCreatorId,
  }) : super(ReadDailyAnonInvoicesInitial()) {
    final todayMidnight = DateTimeTool.getTodayMidnight();
    startDate = todayMidnight;
    if (defaultCreatorId != null) {
      userCreatorId = defaultCreatorId;
    }
  }

  final String? defaultCreatorId;
  DateTime? startDate;
  int offset = 0;
  String? userCreatorId;
  String? _lastBranchId;

  bool isLastPage = false;

  final InvoicesRepository invoicesRepository;

  Future<void> loadDailyPaidAnonInvoices(String branchId, {DateTime? startDate, String? userCreatorId}) async {
    _lastBranchId = branchId;
    emit(ReadDailyAnonInvoicesLoading());
    if (startDate != null) {
      this.startDate = startDate;
    }
    this.userCreatorId = defaultCreatorId ?? userCreatorId ?? this.userCreatorId;
    offset = 0;
    try {
      final topEndDate = this.startDate?.add(const Duration(days: 1));
      final result = await invoicesRepository.getPaidInvoices(
        branchId: branchId,
        clientId: kSaleClientId,
        startDate: this.startDate?.millisecondsSinceEpoch,
        endDate: topEndDate?.millisecondsSinceEpoch,
        offset: offset,
        userCreatorId: this.userCreatorId,
      );

      final totals = await invoicesRepository.getTotalFromPaidInvoices(
        branchId: branchId,
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

  Future<void> nextPage(String branchId) async {
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
        branchId: branchId,
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
    userCreatorId = defaultCreatorId;
    if (_lastBranchId != null) {
      loadDailyPaidAnonInvoices(_lastBranchId!, startDate: startDate, userCreatorId: userCreatorId);
    }
  }
}
