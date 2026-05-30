import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/devolution/devolution.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

part 'read_pending_invoice_state.dart';

class ReadPendingInvoiceCubit extends Cubit<ReadInvoiceState> {
  ReadPendingInvoiceCubit({required this.invoicesRepository, required this.devolutionsRepository})
    : super(ReadInvoiceInitial());

  final InvoicesRepository invoicesRepository;
  final DevolutionsRepository devolutionsRepository;

  bool isLastPage = false;
  List<InvoiceInDb> _invoicesCache = [];

  Future<void> loadPaginatedInvoices(String clientId, String branchId) async {
    emit(ReadInvoiceLoading());
    try {
      final res = await Future.wait([
        invoicesRepository.getPendingInvoices(clientId),
        devolutionsRepository.getAllActiveDevolutions(clientId, branchId),
      ]);
      final response = res[0] as ListResponse<InvoiceInDb>;
      final devolutions = res[1] as List<DevolutionInDb>;

      _invoicesCache = response.data;
      if (_invoicesCache.length >= response.count) {
        isLastPage = true;
      } else {
        isLastPage = false;
      }
      if (isClosed) return;
      emit(
        ReadInvoiceSuccess(
          _invoicesCache,
          response.count,
          devolutions: devolutions,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(ReadInvoiceError(error.toString()));
    }
  }
}
