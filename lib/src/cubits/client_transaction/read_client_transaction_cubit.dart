import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/domain/models/client_transaction/client_transaction.dart';
import 'package:kardex_app_front/src/domain/query_params/client_transaction_query_params.dart';
import 'package:kardex_app_front/src/domain/repositories/client_transaction_repository.dart';

import 'package:kardex_app_front/src/tools/constant.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

part 'read_client_transaction_state.dart';

class ReadClientTransactionCubit extends Cubit<ReadClientTransactionState> {
  ReadClientTransactionCubit({required this.transactionsRepository}) : super(ReadClientTransactionInitial());

  final ClientTransactionsRepository transactionsRepository;

  bool isLastPage = false;
  List<ClientTransactionInDb> _transactionsCache = [];

  late ClientTransactionQueryParams queryParams;
  late ClientInDb client;

  Future<void> loadPaginatedTransactions({
    required ClientInDb client,
    DateTime? endDate,
    DateTime? startDate,
  }) async {
    emit(ReadClientTransactionLoading());
    this.client = client;

    queryParams = ClientTransactionQueryParams(
      offset: 0,
      limit: paginationItems,
      clientId: client.id,
      endDate: endDate?.endOfDay().millisecondsSinceEpoch,
      startDate: startDate?.startOfDay().millisecondsSinceEpoch,
    );

    _transactionsCache = [];
    isLastPage = false;

    await _fetchData();
  }

  Future<void> refresh() async {
    queryParams.offset = 0;
    _transactionsCache = [];
    isLastPage = false;

    emit(ReadClientTransactionLoading());
    await _fetchData();
  }

  Future<void> getNextPage() async {
    if (state is FetchingNextPage) return;
    if (isLastPage) return;

    final currentState = state;
    if (currentState is! ReadClientTransactionSuccess) return;

    emit(
      FetchingNextPage(
        currentState.transactions,
        currentState.totalCount,
        client: currentState.client,
      ),
    );

    try {
      queryParams.offset = _transactionsCache.length;

      final response = await transactionsRepository.getAllClientTransactions(queryParams);

      _transactionsCache.addAll(response.data);

      if (paginationItems > response.data.length) {
        isLastPage = true;
      } else {
        isLastPage = false;
      }

      if (isClosed) return;
      emit(
        ReadClientTransactionSuccess(
          _transactionsCache,
          response.count,
          client: client,
        ),
      );
    } catch (e) {
      log(e.toString());
    }
  }

  void setFilterParams({
    DateTime? endDate,
    TransactionType? type,
    TransactionSubType? subtype,
  }) {
    if (endDate != null) {
      queryParams.endDate = endDate.endOfDay().millisecondsSinceEpoch;
    }
    queryParams.type = type;
    queryParams.subtype = subtype;

    _transactionsCache = [];
    isLastPage = false;
  }

  Future<void> _fetchData() async {
    try {
      final response = await transactionsRepository.getAllClientTransactions(queryParams);

      _transactionsCache = response.data;

      if (paginationItems > response.data.length) {
        isLastPage = true;
      } else {
        isLastPage = false;
      }

      if (isClosed) return;
      emit(
        ReadClientTransactionSuccess(
          _transactionsCache,
          response.count,
          client: client,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(ReadClientTransactionError(error.toString()));
    }
  }
}
