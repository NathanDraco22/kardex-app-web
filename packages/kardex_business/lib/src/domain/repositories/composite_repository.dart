import 'package:kardex_business/src/data/composite_data_source.dart';
import 'package:kardex_business/src/domain/models/composite/client_pending_invoices_composite.dart';
import 'package:kardex_business/src/domain/models/composite/shift_arqueo_composite.dart';

class CompositeRepository {
  final CompositeDataSource compositeDataSource;

  CompositeRepository(this.compositeDataSource);

  Future<ClientPendingInvoicesComposite> getClientPendingInvoices({
    required String clientId,
    required String branchId,
  }) async {
    final result = await compositeDataSource.getClientPendingInvoices(
      clientId: clientId,
      branchId: branchId,
    );
    return ClientPendingInvoicesComposite.fromJson(result);
  }

  Future<ShiftArqueoResponse> getShiftArqueo({
    required String shiftId,
    bool includeDocuments = true,
    int documentsLimit = 500,
  }) async {
    final result = await compositeDataSource.getShiftArqueo(
      shiftId: shiftId,
      includeDocuments: includeDocuments,
      documentsLimit: documentsLimit,
    );
    return ShiftArqueoResponse.fromJson(result);
  }
}
