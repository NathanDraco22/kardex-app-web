import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/receipt/receipt_model.dart';
import 'package:kardex_app_front/src/domain/models/receipt/receipt_total.dart';
import 'package:kardex_app_front/src/domain/query_params/receipt_query_params.dart';
import 'package:kardex_app_front/src/domain/repositories/receipt_repository.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

part 'read_daily_receipt_state.dart';

class ReadDailyReceiptsCubit extends Cubit<ReadDailyReceiptsState> {
  ReadDailyReceiptsCubit({required this.receiptsRepository}) : super(ReadDailyReceiptsInitial()) {
    currentStartDate = DateTimeTool.getTodayMidnight();
  }

  final ReceiptsRepository receiptsRepository;

  bool isLastPage = false;
  List<ReceiptInDb> _receiptsCache = [];

  DateTime? currentStartDate;
  String? currentClientId;

  Future<void> loadDailyReceipts() async {
    emit(ReadDailyReceiptsLoading());
    try {
      final topEndDate = currentStartDate?.add(const Duration(days: 1));
      final queryParams = ReceiptQueryParams(
        offset: 0,
        clientId: currentClientId,
        startDate: currentStartDate?.millisecondsSinceEpoch,
        endDate: topEndDate?.millisecondsSinceEpoch,
      );

      final results = await Future.wait([
        receiptsRepository.getAllReceipts(queryParams),
        receiptsRepository.getReceiptTotal(queryParams),
      ]);

      final receiptResponse = results[0] as ListResponse<ReceiptInDb>;
      final totals = results[1] as ReceiptTotal;

      _receiptsCache = receiptResponse.data;
      if (_receiptsCache.length >= receiptResponse.count) {
        isLastPage = true;
      } else {
        isLastPage = false;
      }
      if (isClosed) return;
      emit(ReadDailyReceiptsSuccess(_receiptsCache, receiptResponse.count, totals));
    } catch (e) {
      if (isClosed) return;
      emit(ReadDailyReceiptsError(e.toString()));
    }
  }

  Future<void> nextPage() async {
    final currentState = state;
    if (isLastPage || currentState is! ReadDailyReceiptsSuccess) return;

    emit(ReadSearchingReceipt(currentState.receipts, currentState.totalCount, currentState.totals));
    try {
      final topEndDate = currentStartDate?.add(const Duration(days: 1));
      final queryParams = ReceiptQueryParams(
        offset: currentState.receipts.length,
        clientId: currentClientId,
        startDate: currentStartDate?.millisecondsSinceEpoch,
        endDate: topEndDate?.millisecondsSinceEpoch,
      );

      final result = await receiptsRepository.getAllReceipts(queryParams);

      _receiptsCache.addAll(result.data);
      if (_receiptsCache.length >= result.data.length) {
        isLastPage = true;
      }
      if (isClosed) return;
      emit(ReadDailyReceiptsSuccess(_receiptsCache, result.data.length, currentState.totals));
    } catch (e) {
      log(e.toString());
    }
  }

  void setFilterParams({String? clientId, DateTime? startDate}) {
    currentClientId = clientId;
    if (startDate != null) {
      currentStartDate = DateTime(startDate.year, startDate.month, startDate.day);
    }
    _receiptsCache = [];
    isLastPage = false;
  }

  void clearFilterParams() {
    currentClientId = null;
    currentStartDate = DateTimeTool.getTodayMidnight();
    _receiptsCache = [];
    isLastPage = false;
    loadDailyReceipts();
  }
}
