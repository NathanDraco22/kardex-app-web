import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_pending_invoice_state.dart';

class ReadPendingInvoiceCubit extends Cubit<ReadInvoiceState> {
  ReadPendingInvoiceCubit({
    this.invoicesRepository,
    this.devolutionsRepository,
    this.creditNotesRepository,
    this.compositeRepository,
  }) : super(ReadInvoiceInitial());

  final InvoicesRepository? invoicesRepository;
  final DevolutionsRepository? devolutionsRepository;
  final CreditNotesRepository? creditNotesRepository;
  final CompositeRepository? compositeRepository;

  bool isLastPage = false;
  List<InvoiceInDb> _invoicesCache = [];

  Future<void> loadPaginatedInvoices(String clientId, String branchId) async {
    emit(ReadInvoiceLoading());
    try {
      if (compositeRepository != null) {
        final composite = await compositeRepository!.getClientPendingInvoices(
          clientId: clientId,
          branchId: branchId,
        );

        _invoicesCache = composite.invoices;
        isLastPage = true;

        if (isClosed) return;
        emit(
          ReadInvoiceSuccess(
            _invoicesCache,
            composite.invoices.length,
            devolutions: composite.devolutions,
            creditNotes: composite.creditNotes,
            summary: composite.summary,
          ),
        );
        return;
      }

      final res = await Future.wait([
        if (invoicesRepository != null)
          invoicesRepository!.getPendingInvoices(clientId)
        else
          Future.value(ListResponse<InvoiceInDb>(data: [], count: 0)),
        if (devolutionsRepository != null)
          devolutionsRepository!.getAllActiveDevolutions(clientId, branchId)
        else
          Future.value(<DevolutionInDb>[]),
        if (creditNotesRepository != null)
          creditNotesRepository!.getCreditNotesByClientId(
            clientId,
            status: CreditNoteStatus.confirmed,
          )
        else
          Future.value(<CreditNoteInDb>[]),
      ]);
      final response = res[0] as ListResponse<InvoiceInDb>;
      final devolutions = res[1] as List<DevolutionInDb>;
      final creditNotes = res[2] as List<CreditNoteInDb>;

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
          creditNotes: creditNotes,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(ReadInvoiceError(error.toString()));
    }
  }
}
