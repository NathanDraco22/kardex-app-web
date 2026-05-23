import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/query_params/history_params.dart';
import 'package:kardex_app_front/src/domain/repositories/invoice_repository.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

part 'read_invoice_by_product_state.dart';

class ReadInvoiceByProductCubit extends Cubit<ReadInvoiceByProductState> {
  ReadInvoiceByProductCubit(this.invoicesRepository) : super(ReadInvoiceByProductInitial());

  final InvoicesRepository invoicesRepository;

  InvoiceQueryParams params = InvoiceQueryParams()
    ..endDate = DateTime.now().endOfDay()
    ..startDate = DateTime.now().startOfDay();
  bool _isLastPage = false;
  late String _productId;

  Future<void> loadInvoicesByProduct(String productId) async {
    _productId = productId;
    emit(ReadInvoiceByProductLoading());
    params.offset = 0;
    params.branchId = BranchesTool.getCurrentBranchId();

    try {
      final listResponse = await invoicesRepository.getInvoicesByProduct(_productId, params);
      final invoices = listResponse.data;

      _isLastPage = invoices.length < params.limit;
      params.offset += invoices.length;

      emit(ReadInvoiceByProductSuccess(invoices));
    } catch (error) {
      emit(ReadInvoiceByProductError(error.toString()));
    }
  }

  Future<void> nextPage() async {
    if (_isLastPage) return;
    final currentState = state;
    if (currentState is! ReadInvoiceByProductSuccess) return;
    if (currentState is FetchingNextPageInvoiceByProduct) return;

    try {
      emit(FetchingNextPageInvoiceByProduct(currentState.invoices));
      final listResponse = await invoicesRepository.getInvoicesByProduct(_productId, params);
      final invoices = listResponse.data;

      _isLastPage = invoices.length < params.limit;
      params.offset += invoices.length;

      emit(
        ReadInvoiceByProductSuccess(
          [...currentState.invoices, ...invoices],
        ),
      );
    } catch (e) {
      emit(ReadInvoiceByProductError(e.toString()));
    }
  }

  void setDefaultParams() {
    params = InvoiceQueryParams()
      ..endDate = DateTime.now().endOfDay()
      ..startDate = DateTime.now().startOfDay();

    _isLastPage = false;
    if (state is ReadInvoiceByProductSuccess || state is ReadInvoiceByProductError) {
      loadInvoicesByProduct(_productId);
    }
  }
}
