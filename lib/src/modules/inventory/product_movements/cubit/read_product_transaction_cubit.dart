import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/models.dart';
import 'package:kardex_app_front/src/domain/models/product_transaction/product_transaction.dart';
import 'package:kardex_app_front/src/domain/query_params/transaction_query_params.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/constant.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

part 'read_product_transaction_state.dart';

class ReadProductTransactionCubit extends Cubit<ReadProductTransactionState> {
  ReadProductTransactionCubit({required this.transactionsRepository}) : super(ReadProductTransactionInitial());

  final ProductTransactionsRepository transactionsRepository;

  bool isLastPage = false;
  List<ProductTransactionInDb> _transactionsCache = [];

  late TransactionQueryParams queryParams;
  late ProductInDb product;

  Future<void> loadPaginatedTransactions({
    required ProductInDb product,
    required DateTime endDate,
  }) async {
    emit(ReadProductTransactionLoading());
    this.product = product;

    queryParams = TransactionQueryParams(
      offset: 0,
      limit: paginationItems,
      branchId: BranchesTool.getCurrentBranchId(),
      productId: product.id,
      endDate: endDate.endOfDay().millisecondsSinceEpoch,
    );

    _transactionsCache = [];
    isLastPage = false;

    await _fetchData();
  }

  Future<void> refresh() async {
    queryParams.offset = 0;
    _transactionsCache = [];
    isLastPage = false;

    emit(ReadProductTransactionLoading());
    await _fetchData();
  }

  Future<void> getNextPage() async {
    if (state is FetchingNextPage) return;
    if (isLastPage) return;

    final currentState = state;
    if (currentState is! ReadProductTransactionSuccess) return;

    emit(
      FetchingNextPage(
        currentState.transactions,
        currentState.totalCount,
        product: currentState.product,
      ),
    );

    try {
      queryParams.offset = _transactionsCache.length;

      final response = await transactionsRepository.getAllProductTransactions(queryParams);

      _transactionsCache.addAll(response.data);

      if (paginationItems > response.data.length) {
        isLastPage = true;
      } else {
        isLastPage = false;
      }

      if (isClosed) return;
      emit(
        ReadProductTransactionSuccess(
          _transactionsCache,
          response.count,
          product: product,
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
    queryParams.type = type?.name;
    queryParams.subtype = subtype?.name;

    _transactionsCache = [];
    isLastPage = false;
  }

  Future<void> _fetchData() async {
    try {
      final response = await transactionsRepository.getAllProductTransactions(queryParams);

      _transactionsCache = response.data;

      if (paginationItems > response.data.length) {
        isLastPage = true;
      } else {
        isLastPage = false;
      }

      if (isClosed) return;
      emit(
        ReadProductTransactionSuccess(
          _transactionsCache,
          response.count,
          product: product,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(ReadProductTransactionError(error.toString()));
    }
  }
}
