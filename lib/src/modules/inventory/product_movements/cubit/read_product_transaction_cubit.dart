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
    try {
      queryParams = TransactionQueryParams(
        offset: 0,
        limit: paginationItems,
        branchId: BranchesTool.getCurrentBranchId(),
        productId: product.id,
        endDate: endDate.endOfDay().millisecondsSinceEpoch,
      );

      final response = await transactionsRepository.getAllProductTransactions(queryParams);

      _transactionsCache = response.data;
      if (_transactionsCache.length >= response.count) {
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

  Future<void> getNextPage() async {
    if (isLastPage) return;
    try {
      queryParams.offset = _transactionsCache.length;

      final response = await transactionsRepository.getAllProductTransactions(queryParams);

      _transactionsCache.addAll(response.data);
      if (_transactionsCache.length >= response.count) {
        isLastPage = true;
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
    queryParams.endDate = endDate?.millisecondsSinceEpoch;
    queryParams.type = type?.name;
    queryParams.subtype = subtype?.name;
    _transactionsCache = [];
    isLastPage = false;
  }
}
