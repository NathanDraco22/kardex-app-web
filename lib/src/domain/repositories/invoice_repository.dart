import 'package:kardex_app_front/src/data/data.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class InvoicesRepository {
  final InvoicesDataSource invoicesDataSource;

  InvoicesRepository(this.invoicesDataSource);

  Future<InvoiceInDb> createInvoice(CreateInvoice createInvoice) async {
    final result = await invoicesDataSource.createInvoice(createInvoice.toJson());
    final invoice = result["invoice"];
    return InvoiceInDb.fromJson(invoice);
  }

  Future<ListResponse<InvoiceInDb>> getPaginatedInvoices({
    required int offset,
    String? clientId,
    String? startDate,
    String? endDate,
  }) async {
    final results = await invoicesDataSource.getPaginatedInvoices(
      offset: offset,
      clientId: clientId,
      startDate: startDate,
      endDate: endDate,
    );
    final response = ListResponse<InvoiceInDb>.fromJson(
      results,
      InvoiceInDb.fromJson,
    );
    return response;
  }

  Future<InvoiceInDb?> getInvoiceById(String invoiceId) async {
    final result = await invoicesDataSource.getInvoiceById(invoiceId);
    if (result == null) return null;
    return InvoiceInDb.fromJson(result);
  }

  Future<InvoiceInDb?> updateInvoiceById(
    String invoiceId,
    UpdateInvoice invoice,
  ) async {
    final result = await invoicesDataSource.updateInvoiceById(invoiceId, invoice.toJson());
    if (result == null) return null;
    return InvoiceInDb.fromJson(result);
  }
}
